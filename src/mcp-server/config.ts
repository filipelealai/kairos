import { config as loadEnv } from "dotenv";
import { readFileSync, existsSync } from "node:fs";
import { z } from "zod";

loadEnv();

// Suporte a {VAR}_FILE: se setado, carrega o conteúdo do arquivo em VAR.
// Usado pra Docker Swarm secrets (montados em /run/secrets/).
function expandFileEnv() {
  for (const key of Object.keys(process.env)) {
    if (!key.endsWith("_FILE")) continue;
    const target = key.slice(0, -"_FILE".length);
    const path = process.env[key];
    if (!path || !existsSync(path)) continue;
    if (process.env[target]) continue; // direct env var wins
    try {
      process.env[target] = readFileSync(path, "utf8").trim();
    } catch {
      // ignore — schema will fail later if required
    }
  }
}
expandFileEnv();

const Schema = z.object({
  PORT: z.coerce.number().int().positive().default(3333),
  KAIROS_MCP_API_KEY: z.string().min(16, "KAIROS_MCP_API_KEY must be at least 16 chars"),
  KAIROS_REPO_PATH: z.string().default("/app/kairos-repo"),
  KAIROS_SYNC_MODE: z.enum(["cron", "webhook", "off"]).default("cron"),
  KAIROS_SYNC_INTERVAL_SECONDS: z.coerce.number().int().positive().default(60),
  KAIROS_SYNC_BRANCH: z.string().default("filipe-instance"),
  KAIROS_SYNC_REMOTE_URL: z.string().optional(),
  GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON: z.string().optional(),
  GOOGLE_DRIVE_ROOT_FOLDER_ID: z.string().optional(),
  LOG_LEVEL: z.enum(["debug", "info", "warn", "error"]).default("info"),
});

export type Config = z.infer<typeof Schema>;

export function loadConfig(): Config {
  const parsed = Schema.safeParse(process.env);
  if (!parsed.success) {
    console.error("Invalid configuration:");
    for (const issue of parsed.error.issues) {
      console.error(`  - ${issue.path.join(".")}: ${issue.message}`);
    }
    process.exit(1);
  }
  return parsed.data;
}

export function isDriveEnabled(cfg: Config): boolean {
  return Boolean(cfg.GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON && cfg.GOOGLE_DRIVE_ROOT_FOLDER_ID);
}
