/**
 * Local OAuth2 authorization for Kairos MCP Drive integration.
 *
 * Run once on a machine with browser access. Generates a long-lived refresh_token
 * that the production server uses to upload outputs to your personal Drive.
 *
 * Usage:
 *   npm run authorize-drive -- /path/to/client_secret_xxx.json
 *
 * Or pass the JSON content via env:
 *   GOOGLE_OAUTH_CLIENT_JSON='{"installed":{...}}' npm run authorize-drive
 *
 * The script:
 *   1. Spins up a local HTTP listener on http://localhost:54321
 *   2. Prints an auth URL — open it in your browser, log in, consent
 *   3. Captures the redirect, exchanges the code for tokens
 *   4. Prints the JSON to be stored as the kairos_drive_oauth Docker secret
 */
import { createServer } from "node:http";
import { readFileSync } from "node:fs";
import { google } from "googleapis";

const SCOPES = ["https://www.googleapis.com/auth/drive.file"];
const PORT = 54321;
const REDIRECT_URI = `http://localhost:${PORT}/callback`;

async function main() {
  const arg = process.argv[2];
  let clientJson: string | undefined = process.env.GOOGLE_OAUTH_CLIENT_JSON;
  if (arg && !arg.startsWith("--")) {
    clientJson = readFileSync(arg, "utf8");
  }
  if (!clientJson) {
    console.error("Usage:");
    console.error("  npm run authorize-drive -- /path/to/client_secret.json");
    console.error("");
    console.error("Or set GOOGLE_OAUTH_CLIENT_JSON env var.");
    process.exit(1);
  }

  const parsed = JSON.parse(clientJson);
  const installed = parsed.installed ?? parsed.web ?? parsed;
  const { client_id, client_secret } = installed;
  if (!client_id || !client_secret) {
    console.error("client_id or client_secret missing in JSON");
    process.exit(1);
  }

  const oauth2 = new google.auth.OAuth2(client_id, client_secret, REDIRECT_URI);

  const authUrl = oauth2.generateAuthUrl({
    access_type: "offline",
    prompt: "consent",
    scope: SCOPES,
  });

  console.log("");
  console.log("═══════════════════════════════════════════════════════════════");
  console.log(" Kairos MCP — OAuth Authorization");
  console.log("═══════════════════════════════════════════════════════════════");
  console.log("");
  console.log(" 1. Open this URL in your browser:");
  console.log("");
  console.log("    " + authUrl);
  console.log("");
  console.log(" 2. Log in with the Google account that owns the Drive folder");
  console.log(" 3. Click 'Continue' on the unverified-app warning (it's your own)");
  console.log(" 4. Click 'Allow' to grant Drive access");
  console.log("");
  console.log(` Listening on ${REDIRECT_URI} ...`);
  console.log("");

  const code = await new Promise<string>((resolve, reject) => {
    const server = createServer((req, res) => {
      const url = new URL(req.url ?? "/", `http://localhost:${PORT}`);
      const authCode = url.searchParams.get("code");
      const authError = url.searchParams.get("error");
      res.setHeader("Content-Type", "text/html; charset=utf-8");
      if (authCode) {
        res.statusCode = 200;
        res.end(`<!doctype html><html><head><meta charset="utf-8"><title>Authorized</title></head><body style="font-family:system-ui,sans-serif;padding:2em;text-align:center"><h2>✅ Autorização concluída.</h2><p>Pode fechar essa aba e voltar ao terminal.</p></body></html>`);
        server.close();
        resolve(authCode);
      } else {
        res.statusCode = 400;
        res.end(`<!doctype html><html><body><h2>❌ Erro</h2><p>${authError ?? "no code"}</p></body></html>`);
        server.close();
        reject(new Error(authError ?? "no code in callback"));
      }
    });
    server.on("error", reject);
    server.listen(PORT);
  });

  const { tokens } = await oauth2.getToken(code);
  if (!tokens.refresh_token) {
    console.error("");
    console.error("❌ No refresh_token returned by Google.");
    console.error("");
    console.error("This usually happens when you've already authorized this client before.");
    console.error("Solution: revoke access at https://myaccount.google.com/permissions");
    console.error("(find 'Kairos MCP Server'), then rerun this script.");
    process.exit(1);
  }

  const result = {
    client_id,
    client_secret,
    refresh_token: tokens.refresh_token,
  };

  console.log("");
  console.log("═══════════════════════════════════════════════════════════════");
  console.log(" ✅ Authorization complete!");
  console.log("═══════════════════════════════════════════════════════════════");
  console.log("");
  console.log(" Save this JSON as the 'kairos_drive_oauth' secret in 1Password:");
  console.log("");
  console.log(JSON.stringify(result, null, 2));
  console.log("");
  console.log(" Then paste the JSON to @kairos to update the Docker secret on the VPS.");
  console.log("");
}

main().catch((err) => {
  console.error("");
  console.error("Error:", err);
  process.exit(1);
});
