import { google } from "googleapis";
import { Readable } from "node:stream";
import { log } from "./logger.js";
import type { Config } from "./config.js";

const FOLDER_MIME = "application/vnd.google-apps.folder";

interface DriveClient {
  uploadFile(opts: { folderPath: string; filename: string; content: string }): Promise<string>;
}

export async function makeDriveClient(cfg: Config): Promise<DriveClient | null> {
  if (!cfg.GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON || !cfg.GOOGLE_DRIVE_ROOT_FOLDER_ID) {
    log.warn("Drive client disabled — GOOGLE_DRIVE_* env vars not set");
    return null;
  }

  let credentials: Record<string, unknown>;
  try {
    credentials = JSON.parse(cfg.GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON);
  } catch (err) {
    log.error("Failed to parse GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON", { error: String(err) });
    return null;
  }

  const auth = new google.auth.GoogleAuth({
    credentials,
    scopes: ["https://www.googleapis.com/auth/drive.file"],
  });
  const drive = google.drive({ version: "v3", auth });
  const rootId = cfg.GOOGLE_DRIVE_ROOT_FOLDER_ID;
  const folderCache = new Map<string, string>();
  folderCache.set("", rootId);

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
