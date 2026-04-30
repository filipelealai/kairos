import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { log } from "./logger.js";
import type { Config } from "./config.js";

function runGit(args: string[], cwd: string, timeoutMs = 60_000): Promise<{ code: number; stdout: string; stderr: string }> {
  return new Promise((resolve) => {
    const child = spawn("git", args, { cwd, env: process.env });
    let stdout = "";
    let stderr = "";
    const timer = setTimeout(() => child.kill("SIGTERM"), timeoutMs);
    child.stdout.on("data", (b) => (stdout += b.toString()));
    child.stderr.on("data", (b) => (stderr += b.toString()));
    child.on("close", (code) => {
      clearTimeout(timer);
      resolve({ code: code ?? -1, stdout, stderr });
    });
  });
}

export async function ensureRepoCloned(cfg: Config): Promise<void> {
  if (cfg.KAIROS_SYNC_MODE === "off") {
    log.info("Git sync disabled (KAIROS_SYNC_MODE=off)");
    return;
  }
  const repoDotGit = `${cfg.KAIROS_REPO_PATH}/.git`;
  if (existsSync(repoDotGit)) {
    log.info("Repo already cloned", { path: cfg.KAIROS_REPO_PATH });
    return;
  }
  if (!cfg.KAIROS_SYNC_REMOTE_URL) {
    log.error("Repo not cloned and KAIROS_SYNC_REMOTE_URL not set");
    throw new Error("Repo missing and no remote URL provided");
  }
  log.info("Cloning repo", {
    remote: cfg.KAIROS_SYNC_REMOTE_URL.replace(/:\/\/[^@]+@/, "://***@"),
    branch: cfg.KAIROS_SYNC_BRANCH,
    target: cfg.KAIROS_REPO_PATH,
  });
  const cloned = await runGit(
    ["clone", "--branch", cfg.KAIROS_SYNC_BRANCH, "--single-branch", cfg.KAIROS_SYNC_REMOTE_URL, cfg.KAIROS_REPO_PATH],
    "/",
    300_000,
  );
  if (cloned.code !== 0) {
    log.error("Clone failed", { stderr: cloned.stderr });
    throw new Error(`git clone failed: ${cloned.stderr}`);
  }
  log.info("Clone complete");
}

export async function pullRepo(cfg: Config): Promise<{ changed: boolean; head: string }> {
  const before = await runGit(["rev-parse", "HEAD"], cfg.KAIROS_REPO_PATH);
  const fetch = await runGit(["fetch", "origin", cfg.KAIROS_SYNC_BRANCH], cfg.KAIROS_REPO_PATH);
  if (fetch.code !== 0) {
    log.warn("git fetch failed", { stderr: fetch.stderr });
    return { changed: false, head: before.stdout.trim() };
  }
  const reset = await runGit(
    ["reset", "--hard", `origin/${cfg.KAIROS_SYNC_BRANCH}`],
    cfg.KAIROS_REPO_PATH,
  );
  if (reset.code !== 0) {
    log.warn("git reset failed", { stderr: reset.stderr });
    return { changed: false, head: before.stdout.trim() };
  }
  const after = await runGit(["rev-parse", "HEAD"], cfg.KAIROS_REPO_PATH);
  const head = after.stdout.trim();
  const changed = head !== before.stdout.trim();
  if (changed) log.info("Repo updated", { previous: before.stdout.trim(), head });
  return { changed, head };
}

export function startSyncLoop(cfg: Config, onChange: () => void): NodeJS.Timeout | null {
  if (cfg.KAIROS_SYNC_MODE !== "cron") return null;
  log.info("Starting git sync loop", { interval_seconds: cfg.KAIROS_SYNC_INTERVAL_SECONDS });
  const interval = setInterval(async () => {
    try {
      const { changed } = await pullRepo(cfg);
      if (changed) onChange();
    } catch (err) {
      log.warn("Sync iteration failed", { error: String(err) });
    }
  }, cfg.KAIROS_SYNC_INTERVAL_SECONDS * 1000);
  return interval;
}
