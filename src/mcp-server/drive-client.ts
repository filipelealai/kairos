import { google } from "googleapis";
import { Readable } from "node:stream";
import { log } from "./logger.js";
import type { Config } from "./config.js";

const FOLDER_MIME = "application/vnd.google-apps.folder";

interface DriveClient {
  uploadFile(opts: { folderPath: string; filename: string; content: string }): Promise<string>;
}

interface OAuthCredentials {
  client_id: string;
  client_secret: string;
  refresh_token: string;
}

export async function makeDriveClient(cfg: Config): Promise<DriveClient | null> {
  if (!cfg.GOOGLE_DRIVE_OAUTH_JSON || !cfg.GOOGLE_DRIVE_ROOT_FOLDER_ID) {
    log.warn("Drive client disabled — GOOGLE_DRIVE_* env vars not set");
    return null;
  }

  let credentials: OAuthCredentials;
  try {
    credentials = JSON.parse(cfg.GOOGLE_DRIVE_OAUTH_JSON);
  } catch (err) {
    log.error("Failed to parse GOOGLE_DRIVE_OAUTH_JSON", { error: String(err) });
    return null;
  }

  if (!credentials.client_id || !credentials.client_secret || !credentials.refresh_token) {
    log.error("GOOGLE_DRIVE_OAUTH_JSON missing required fields (client_id, client_secret, refresh_token)");
    return null;
  }

  const oauth2Client = new google.auth.OAuth2(credentials.client_id, credentials.client_secret);
  oauth2Client.setCredentials({ refresh_token: credentials.refresh_token });

  const drive = google.drive({ version: "v3", auth: oauth2Client });
  const rootId = cfg.GOOGLE_DRIVE_ROOT_FOLDER_ID;
  const folderCache = new Map<string, string>();
  folderCache.set("", rootId);

  log.info("Drive client initialized (OAuth)", {
    rootFolderId: rootId,
    clientIdPrefix: credentials.client_id.slice(0, 12) + "...",
  });

  async function ensureFolder(relPath: string): Promise<string> {
    if (folderCache.has(relPath)) return folderCache.get(relPath)!;
    const segments = relPath.split("/").filter(Boolean);
    let parentId = rootId;
    let acc = "";
    for (const segment of segments) {
      acc = acc ? `${acc}/${segment}` : segment;
      if (folderCache.has(acc)) {
        parentId = folderCache.get(acc)!;
        continue;
      }
      const escaped = segment.replace(/'/g, "\\'");
      const search = await drive.files.list({
        q: `'${parentId}' in parents and name='${escaped}' and mimeType='${FOLDER_MIME}' and trashed=false`,
        fields: "files(id,name)",
        spaces: "drive",
      });
      const found = search.data.files?.[0];
      if (found?.id) {
        parentId = found.id;
      } else {
        const created = await drive.files.create({
          requestBody: { name: segment, mimeType: FOLDER_MIME, parents: [parentId] },
          fields: "id",
        });
        if (!created.data.id) throw new Error(`Failed to create folder ${segment}`);
        parentId = created.data.id;
      }
      folderCache.set(acc, parentId);
    }
    return parentId;
  }

  return {
    async uploadFile({ folderPath, filename, content }) {
      const folderId = await ensureFolder(folderPath);
      const escaped = filename.replace(/'/g, "\\'");
      const existing = await drive.files.list({
        q: `'${folderId}' in parents and name='${escaped}' and trashed=false`,
        fields: "files(id,name)",
        spaces: "drive",
      });
      const stream = Readable.from(content);
      if (existing.data.files?.[0]?.id) {
        const fileId = existing.data.files[0].id;
        await drive.files.update({
          fileId,
          media: { mimeType: "text/markdown", body: stream },
        });
        log.info("Drive: file updated", { fileId, filename, folderPath });
        return fileId;
      }
      const created = await drive.files.create({
        requestBody: { name: filename, parents: [folderId] },
        media: { mimeType: "text/markdown", body: stream },
        fields: "id",
      });
      if (!created.data.id) throw new Error("Drive create returned no id");
      log.info("Drive: file created", { fileId: created.data.id, filename, folderPath });
      return created.data.id;
    },
  };
}
