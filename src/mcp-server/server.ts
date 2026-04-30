import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { spawn } from "node:child_process";
import { mkdir, writeFile, readFile, readdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { z } from "zod";
import { log } from "./logger.js";
import { loadOperationalAgents, type OperationalAgent } from "./agent-registry.js";
import { loadAgentContext, renderAgentSystemMessage } from "./context-loader.js";
import { createJob, getJob, updateJob, listJobs } from "./job-queue.js";
import { makeDriveClient } from "./drive-client.js";
import type { Config } from "./config.js";

interface ServerState {
  agents: OperationalAgent[];
  drive: Awaited<ReturnType<typeof makeDriveClient>>;
}

export async function buildMcpServer(cfg: Config): Promise<McpServer> {
  const state: ServerState = {
    agents: await loadOperationalAgents(cfg.KAIROS_REPO_PATH),
    drive: await makeDriveClient(cfg),
  };

  const server = new McpServer(
    { name: "kairos-mcp", version: "1.0.0" },
    { capabilities: { resources: {}, tools: {}, prompts: {} } },
  );

  registerPrompts(server, cfg, state);
  registerResources(server, cfg, state);
  registerTools(server, cfg, state);

  return server;
}

export async function reloadAgentRegistry(server: McpServer, cfg: Config, state: ServerState): Promise<void> {
  state.agents = await loadOperationalAgents(cfg.KAIROS_REPO_PATH);
  log.info("Agent registry reloaded", { count: state.agents.length });
}

// ─── Prompts ────────────────────────────────────────────────────────────────

function registerPrompts(server: McpServer, cfg: Config, state: ServerState): void {
  for (const agent of state.agents) {
    const promptName = `kairos-${agent.squad}-${agent.id}`;
    const description = `Ativar agente @${agent.id} do squad ${agent.squad}`;

    server.prompt(
      promptName,
      description,
      async () => {
        const ctx = await loadAgentContext(cfg.KAIROS_REPO_PATH, agent);
        const content = renderAgentSystemMessage(ctx);
        return {
          messages: [
            {
              role: "user" as const,
              content: { type: "text" as const, text: content },
            },
          ],
        };
      },
    );
  }
}

// ─── Resources ──────────────────────────────────────────────────────────────

function registerResources(server: McpServer, cfg: Config, state: ServerState): void {
  server.resource(
    "agents-index",
    "kairos://agents",
    { mimeType: "application/json", description: "Lista de agentes operacionais expostos pelo MCP" },
    async () => ({
      contents: [
        {
          uri: "kairos://agents",
          mimeType: "application/json",
          text: JSON.stringify(
            state.agents.map((a) => ({ id: a.id, squad: a.squad })),
            null,
            2,
          ),
        },
      ],
    }),
  );

  server.resource(
    "agent-context",
    "kairos://agent/{id}",
    { mimeType: "text/markdown", description: "Contexto completo do agente (persona + rules + memory + templates)" },
    async (uri) => {
      const id = uri.pathname.replace(/^\/+/, "").replace(/\/.*$/, "");
      const agent = state.agents.find((a) => a.id === id);
      if (!agent) throw new Error(`Agent not found or not exposed: ${id}`);
      const ctx = await loadAgentContext(cfg.KAIROS_REPO_PATH, agent);
      return {
        contents: [
          {
            uri: uri.toString(),
            mimeType: "text/markdown",
            text: renderAgentSystemMessage(ctx),
          },
        ],
      };
    },
  );
}

// ─── Tools ──────────────────────────────────────────────────────────────────

function registerTools(server: McpServer, cfg: Config, state: ServerState): void {
  // execute_script — async job pattern
  server.tool(
    "execute_script",
    "Executa um script TypeScript do squad de forma assíncrona. Retorna job_id imediatamente; use check_job para acompanhar.",
    {
      script_path: z.string().describe("Path relativo ao repo (ex: src/agents/lead-scorer.ts)"),
      args: z.array(z.string()).optional().describe("Argumentos posicionais para o script"),
    },
    async ({ script_path, args }) => {
      if (script_path.includes("..")) throw new Error("script_path may not contain ..");
      const fullPath = join(cfg.KAIROS_REPO_PATH, script_path);
      if (!existsSync(fullPath)) throw new Error(`Script not found: ${script_path}`);

      const finalArgs = ["tsx", script_path, ...(args ?? [])];
      const job = createJob("npx", finalArgs, cfg.KAIROS_REPO_PATH);

      const child = spawn("npx", finalArgs, {
        cwd: cfg.KAIROS_REPO_PATH,
        env: process.env,
      });
      child.stdout.on("data", (b) => updateJob(job.id, { stdout: getJob(job.id)!.stdout + b.toString() }));
      child.stderr.on("data", (b) => updateJob(job.id, { stderr: getJob(job.id)!.stderr + b.toString() }));
      child.on("close", (code) => {
        updateJob(job.id, {
          status: code === 0 ? "done" : "failed",
          exitCode: code ?? -1,
          finishedAt: new Date().toISOString(),
        });
      });
      child.on("error", (err) => {
        updateJob(job.id, {
          status: "failed",
          error: String(err),
          finishedAt: new Date().toISOString(),
        });
      });

      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify({ job_id: job.id, status: "running" }, null, 2),
          },
        ],
      };
    },
  );

  // check_job
  server.tool(
    "check_job",
    "Consulta o status e o resultado de um job iniciado com execute_script.",
    {
      job_id: z.string().describe("ID retornado por execute_script"),
    },
    async ({ job_id }) => {
      const job = getJob(job_id);
      if (!job) throw new Error(`Job not found: ${job_id}`);
      const summary = {
        id: job.id,
        status: job.status,
        startedAt: job.startedAt,
        finishedAt: job.finishedAt,
        exitCode: job.exitCode,
        stdout_tail: job.stdout.slice(-4000),
        stderr_tail: job.stderr.slice(-2000),
        error: job.error,
      };
      return { content: [{ type: "text" as const, text: JSON.stringify(summary, null, 2) }] };
    },
  );

  // list_jobs
  server.tool(
    "list_jobs",
    "Lista os últimos jobs executados (até 50, em memória).",
    {},
    async () => {
      const jobs = listJobs().map((j) => ({
        id: j.id,
        status: j.status,
        command: `${j.command} ${j.args.join(" ")}`,
        startedAt: j.startedAt,
        finishedAt: j.finishedAt,
        exitCode: j.exitCode,
      }));
      return { content: [{ type: "text" as const, text: JSON.stringify(jobs, null, 2) }] };
    },
  );

  // save_output
  server.tool(
    "save_output",
    "Salva um output do agente em data/outputs/{squad}/{subdir}/ no contêiner E faz upload para a pasta correspondente no Google Drive (se Drive habilitado).",
    {
      squad: z.string().describe("Nome do squad (ex: cold-prospecting)"),
      subdir: z.string().describe("Subdiretório dentro de data/outputs/{squad}/ (ex: emails, briefs, proposals)"),
      filename: z.string().describe("Nome do arquivo (ex: email-writer_emails-2026-04-29.json)"),
      content: z.string().describe("Conteúdo do arquivo"),
    },
    async ({ squad, subdir, filename, content }) => {
      if (squad.includes("..") || subdir.includes("..") || filename.includes("/")) {
        throw new Error("squad/subdir cannot contain '..' and filename cannot contain '/'");
      }
      const relDir = join("data/outputs", squad, subdir);
      const fullPath = join(cfg.KAIROS_REPO_PATH, relDir, filename);
      await mkdir(dirname(fullPath), { recursive: true });
      await writeFile(fullPath, content, "utf8");

      let driveResult: { fileId: string } | null = null;
      if (state.drive) {
        try {
          const fileId = await state.drive.uploadFile({
            folderPath: `${squad}/${subdir}`,
            filename,
            content,
          });
          driveResult = { fileId };
        } catch (err) {
          log.warn("Drive upload failed", { error: String(err), filename });
        }
      }

      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(
              {
                local_path: join(relDir, filename),
                drive: driveResult ?? "disabled",
              },
              null,
              2,
            ),
          },
        ],
      };
    },
  );

  // list_outputs
  server.tool(
    "list_outputs",
    "Lista outputs recentes de um squad em data/outputs/{squad}/.",
    {
      squad: z.string(),
      subdir: z.string().optional().describe("Filtrar por subdiretório"),
    },
    async ({ squad, subdir }) => {
      const base = subdir
        ? join(cfg.KAIROS_REPO_PATH, "data/outputs", squad, subdir)
        : join(cfg.KAIROS_REPO_PATH, "data/outputs", squad);
      if (!existsSync(base)) {
        return { content: [{ type: "text" as const, text: "[]" }] };
      }
      const result: string[] = [];
      await collectFiles(base, base, result);
      return { content: [{ type: "text" as const, text: JSON.stringify(result.sort().reverse(), null, 2) }] };
    },
  );

  // read_handoff
  server.tool(
    "read_handoff",
    "Lê o handoff pendente mais recente direcionado ao agente (consumed=false).",
    {
      to_agent: z.string().describe("ID do agente que está consumindo o handoff"),
    },
    async ({ to_agent }) => {
      const dir = join(cfg.KAIROS_REPO_PATH, ".kairos-core/runtime/handoffs");
      if (!existsSync(dir)) {
        return { content: [{ type: "text" as const, text: "{}" }] };
      }
      const entries = await readdir(dir);
      const candidates = entries
        .filter((f) => f.includes(`-to-${to_agent}-`) && f.endsWith(".yaml"))
        .sort()
        .reverse();
      for (const candidate of candidates) {
        const content = await readFile(join(dir, candidate), "utf8");
        if (/consumed:\s*false/.test(content)) {
          return {
            content: [
              {
                type: "text" as const,
                text: JSON.stringify({ filename: candidate, content }, null, 2),
              },
            ],
          };
        }
      }
      return { content: [{ type: "text" as const, text: "{}" }] };
    },
  );

  // write_handoff
  server.tool(
    "write_handoff",
    "Grava um novo handoff em .kairos-core/runtime/handoffs/. O conteúdo deve seguir o protocolo definido em .claude/rules/agent-handoff.md.",
    {
      from_agent: z.string(),
      to_agent: z.string(),
      yaml_content: z.string().describe("Conteúdo YAML completo do handoff (ver protocolo em agent-handoff.md)"),
    },
    async ({ from_agent, to_agent, yaml_content }) => {
      const ts = new Date().toISOString().replace(/[:.]/g, "-");
      const filename = `handoff-${from_agent}-to-${to_agent}-${ts}.yaml`;
      const dir = join(cfg.KAIROS_REPO_PATH, ".kairos-core/runtime/handoffs");
      await mkdir(dir, { recursive: true });
      await writeFile(join(dir, filename), yaml_content, "utf8");
      return {
        content: [
          { type: "text" as const, text: JSON.stringify({ filename, dir: ".kairos-core/runtime/handoffs/" }, null, 2) },
        ],
      };
    },
  );
}

async function collectFiles(root: string, current: string, acc: string[]): Promise<void> {
  const entries = await readdir(current, { withFileTypes: true });
  for (const entry of entries) {
    const full = join(current, entry.name);
    if (entry.isDirectory()) {
      await collectFiles(root, full, acc);
    } else if (entry.isFile()) {
      acc.push(full.slice(root.length + 1));
    }
  }
}
