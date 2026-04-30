import express, { type Request, type Response, type NextFunction } from "express";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { loadConfig } from "./config.js";
import { setLogLevel, log } from "./logger.js";
import { ensureRepoCloned, pullRepo, startSyncLoop } from "./git-sync.js";
import { buildMcpServer } from "./server.js";

async function main() {
  const cfg = loadConfig();
  setLogLevel(cfg.LOG_LEVEL);

  log.info("Starting Kairos MCP Server", {
    repo: cfg.KAIROS_REPO_PATH,
    branch: cfg.KAIROS_SYNC_BRANCH,
    sync_mode: cfg.KAIROS_SYNC_MODE,
  });

  await ensureRepoCloned(cfg);
  if (cfg.KAIROS_SYNC_MODE !== "off") {
    await pullRepo(cfg).catch((err) => log.warn("Initial pull failed", { error: String(err) }));
  }

  const mcp = await buildMcpServer(cfg);

  startSyncLoop(cfg, () => {
    log.info("Repo changed — agent registry will reload on next request");
  });

  const app = express();
  app.use(express.json({ limit: "10mb" }));

  app.get("/health", (_req: Request, res: Response) => {
    res.json({ ok: true, version: "1.0.0", ts: new Date().toISOString() });
  });

  app.use("/mcp", (req: Request, res: Response, next: NextFunction) => {
    const auth = req.header("authorization") ?? "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : auth;
    if (token !== cfg.KAIROS_MCP_API_KEY) {
      log.warn("Unauthorized request", { ip: req.ip });
      res.status(401).json({ error: "unauthorized" });
      return;
    }
    next();
  });

  app.post("/mcp", async (req: Request, res: Response) => {
    try {
      const transport = new StreamableHTTPServerTransport({
        sessionIdGenerator: undefined,
        enableJsonResponse: true,
      });
      res.on("close", () => {
        transport.close().catch(() => {});
      });
      await mcp.connect(transport);
      await transport.handleRequest(req, res, req.body);
    } catch (err) {
      log.error("MCP request failed", { error: String(err) });
      if (!res.headersSent) {
        res.status(500).json({ error: "internal_error", message: String(err) });
      }
    }
  });

  app.get("/mcp", (_req: Request, res: Response) => {
    res.status(405).json({ error: "method_not_allowed", hint: "Use POST /mcp" });
  });

  const server = app.listen(cfg.PORT, "0.0.0.0", () => {
    log.info("Kairos MCP Server listening", { port: cfg.PORT });
  });

  const shutdown = (signal: string) => {
    log.info("Shutting down", { signal });
    server.close(() => process.exit(0));
    setTimeout(() => process.exit(1), 10_000).unref();
  };
  process.on("SIGTERM", () => shutdown("SIGTERM"));
  process.on("SIGINT", () => shutdown("SIGINT"));
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
