import { readFile, readdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { log } from "./logger.js";
import type { OperationalAgent } from "./agent-registry.js";

export interface AgentContext {
  agent: OperationalAgent;
  persona: string;
  squadRules: Array<{ filename: string; content: string }>;
  memory: string | null;
  templates: Array<{ relPath: string; content: string }>;
}

export async function loadAgentContext(
  repoPath: string,
  agent: OperationalAgent
): Promise<AgentContext> {
  const persona = await readSafe(agent.personaPath);
  if (!persona) {
    throw new Error(`Persona not found for agent ${agent.id}: ${agent.personaPath}`);
  }

  const memory = await readSafe(agent.memoryPath);
  const squadRules = await loadSquadRules(repoPath, agent.squad);
  const templates = await loadSquadTemplates(repoPath, agent.squad);

  return { agent, persona, squadRules, memory, templates };
}

async function loadSquadRules(
  repoPath: string,
  squad: string
): Promise<Array<{ filename: string; content: string }>> {
  const rulesDir = join(repoPath, "squads", squad, "rules");
  if (!existsSync(rulesDir)) return [];

  const entries = await readdir(rulesDir);
  const rules: Array<{ filename: string; content: string }> = [];
  for (const entry of entries) {
    if (!entry.endsWith(".md")) continue;
    const content = await readSafe(join(rulesDir, entry));
    if (content) rules.push({ filename: entry, content });
  }
  return rules;
}

async function loadSquadTemplates(
  repoPath: string,
  squad: string
): Promise<Array<{ relPath: string; content: string }>> {
  const templatesRoot = join(repoPath, "squads", squad, "templates");
  if (!existsSync(templatesRoot)) return [];

  const result: Array<{ relPath: string; content: string }> = [];
  await walkMarkdown(templatesRoot, templatesRoot, result);
  return result;
}

async function walkMarkdown(
  root: string,
  current: string,
  acc: Array<{ relPath: string; content: string }>
): Promise<void> {
  const entries = await readdir(current, { withFileTypes: true });
  for (const entry of entries) {
    const full = join(current, entry.name);
    if (entry.isDirectory()) {
      await walkMarkdown(root, full, acc);
    } else if (entry.isFile() && entry.name.endsWith(".md")) {
      const content = await readSafe(full);
      if (content) {
        const relPath = full.slice(root.length + 1);
        acc.push({ relPath, content });
      }
    }
  }
}

async function readSafe(path: string): Promise<string | null> {
  try {
    return await readFile(path, "utf8");
  } catch (err) {
    log.debug("File not readable", { path, error: String(err) });
    return null;
  }
}

export function renderAgentSystemMessage(ctx: AgentContext): string {
  const sections: string[] = [];
  sections.push(
    `# Kairos Agent Activation — @${ctx.agent.id}`,
    "",
    `Você está sendo ativado como o agente **@${ctx.agent.id}** do squad **${ctx.agent.squad}** do Kairos.`,
    "Os blocos abaixo carregam o contexto completo desse agente — persona, rules do squad, memória persistente e templates disponíveis.",
    "Siga a persona e use as ferramentas (tools) MCP do servidor Kairos para executar scripts, salvar outputs e ler/escrever handoffs conforme necessário.",
    "",
    "---",
    "",
    "## Persona",
    "",
    ctx.persona.trim(),
  );

  if (ctx.squadRules.length > 0) {
    sections.push("", "---", "", `## Rules do squad ${ctx.agent.squad}`, "");
    for (const rule of ctx.squadRules) {
      sections.push(`### ${rule.filename}`, "", rule.content.trim(), "");
    }
  }

  if (ctx.memory) {
    sections.push("", "---", "", `## Memória persistente — @${ctx.agent.id}`, "", ctx.memory.trim());
  }

  if (ctx.templates.length > 0) {
    sections.push(
      "",
      "---",
      "",
      `## Templates disponíveis em squads/${ctx.agent.squad}/templates/`,
      "",
      "Os templates abaixo estão disponíveis como referência. Use-os ao gerar outputs (propostas, contratos, kits de onboarding, etc.) conforme indicado pela persona.",
      "",
    );
    for (const t of ctx.templates) {
      sections.push(`### ${t.relPath}`, "", "```markdown", t.content.trim(), "```", "");
    }
  }

  sections.push(
    "",
    "---",
    "",
    "## Próxima ação",
    "",
    "Aguarde o input do usuário. Quando for executar uma operação que afeta o sistema (rodar script, salvar output, gravar handoff), use as tools MCP do servidor Kairos.",
  );

  return sections.join("\n");
}
