import { readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { parse as parseYaml } from "yaml";
import { log } from "./logger.js";

export interface OperationalAgent {
  id: string;
  squad: string;
  personaPath: string;
  memoryPath: string;
}

interface CoreConfig {
  agents?: {
    master?: string;
    squads?: Record<string, { agents?: string[]; status?: string }>;
  };
  framework?: {
    commandsLocation?: string;
    agentsLocation?: string;
  };
}

const DEFAULT_COMMANDS_LOCATION = ".claude/commands/kairos/agents/";
const DEFAULT_AGENTS_LOCATION = ".kairos-core/agents/";

export async function loadOperationalAgents(repoPath: string): Promise<OperationalAgent[]> {
  const configPath = join(repoPath, ".kairos-core/core-config.yaml");
  if (!existsSync(configPath)) {
    log.error("core-config.yaml not found", { configPath });
    return [];
  }

  const raw = await readFile(configPath, "utf8");
  const config = parseYaml(raw) as CoreConfig;

  const masterAgent = config.agents?.master ?? "kairos";
  const squads = config.agents?.squads ?? {};
  const commandsLocation = config.framework?.commandsLocation ?? DEFAULT_COMMANDS_LOCATION;
  const agentsLocation = config.framework?.agentsLocation ?? DEFAULT_AGENTS_LOCATION;

  const operational: OperationalAgent[] = [];

  for (const [squadName, squadConfig] of Object.entries(squads)) {
    if (squadConfig.status && squadConfig.status !== "active") continue;
    for (const agentId of squadConfig.agents ?? []) {
      if (agentId === masterAgent) continue;
      operational.push({
        id: agentId,
        squad: squadName,
        personaPath: join(repoPath, commandsLocation, `${agentId}.md`),
        memoryPath: join(repoPath, agentsLocation, agentId, "MEMORY.md"),
      });
    }
  }

  log.info("Operational agents loaded", {
    count: operational.length,
    excluded_master: masterAgent,
  });

  return operational;
}
