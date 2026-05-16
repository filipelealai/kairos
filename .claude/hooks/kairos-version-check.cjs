#!/usr/bin/env node
'use strict';

/**
 * kairos-version-check.cjs
 *
 * Hook de SessionStart do Kairos.
 * Verifica se há nova versão do framework disponível no repositório público.
 *
 * Comportamento:
 * - Lê versão local de .kairos-core/core-config.yaml
 * - Consulta a API GitHub (com cache de 1h em .kairos-core/runtime/version-check.json)
 * - Se versão remota > local: imprime aviso no stdout para o Claude Code renderizar
 * - Tolerante a offline: silently skip em caso de falha de rede
 *
 * Stdin: { session_id, cwd, hook_event_name }
 * Stdout: aviso de nova versão (se houver) ou vazio
 */

const HOOK_TIMEOUT_MS = 8000;
const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hora
const CACHE_FILE = '.kairos-core/runtime/version-check.json';
const CONFIG_FILE = '.kairos-core/core-config.yaml';
const DEFAULT_REPO = 'filipelealai/kairos';

const fs = require('fs');
const path = require('path');
const https = require('https');

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    const timeout = setTimeout(() => resolve('{}'), HOOK_TIMEOUT_MS);
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => {
      clearTimeout(timeout);
      resolve(data || '{}');
    });
    process.stdin.on('error', () => {
      clearTimeout(timeout);
      resolve('{}');
    });
  });
}

function readLocalVersion(cwd) {
  try {
    const configPath = path.join(cwd, CONFIG_FILE);
    const content = fs.readFileSync(configPath, 'utf8');
    const match = content.match(/^version:\s*['"]?([^\s'"]+)['"]?/m);
    return match ? match[1].trim() : null;
  } catch (_) {
    return null;
  }
}

function readUpdateSource(cwd) {
  try {
    const configPath = path.join(cwd, CONFIG_FILE);
    const content = fs.readFileSync(configPath, 'utf8');
    const match = content.match(/^update_source:\s*['"]?([^\s'"]+)['"]?/m);
    if (match) {
      // Extrair owner/repo da URL — ex: https://github.com/filipelealai/kairos
      const url = match[1].trim();
      const repoMatch = url.match(/github\.com\/([^/]+\/[^/]+?)(?:\.git)?$/);
      return repoMatch ? repoMatch[1] : DEFAULT_REPO;
    }
    return DEFAULT_REPO;
  } catch (_) {
    return DEFAULT_REPO;
  }
}

function readCache(cwd) {
  try {
    const cachePath = path.join(cwd, CACHE_FILE);
    const raw = fs.readFileSync(cachePath, 'utf8');
    const cache = JSON.parse(raw);
    if (!cache.timestamp || !cache.latest_version) return null;
    if (Date.now() - cache.timestamp > CACHE_TTL_MS) return null;
    return cache.latest_version;
  } catch (_) {
    return null;
  }
}

function writeCache(cwd, version) {
  try {
    const cachePath = path.join(cwd, CACHE_FILE);
    const dir = path.dirname(cachePath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(cachePath, JSON.stringify({
      timestamp: Date.now(),
      latest_version: version,
    }), 'utf8');
  } catch (_) {
    // cache write failure is non-fatal
  }
}

function httpGet(path) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'api.github.com',
      path,
      method: 'GET',
      headers: {
        'User-Agent': 'kairos-version-check/1.0',
        'Accept': 'application/vnd.github+json',
      },
      timeout: 5000,
    };
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', () => resolve(null));
    req.on('timeout', () => { req.destroy(); resolve(null); });
    req.end();
  });
}

async function fetchLatestVersion(repo) {
  // Try releases/latest first (returns 404 if repo has no GitHub Releases)
  const rel = await httpGet(`/repos/${repo}/releases/latest`);
  if (rel && rel.status === 200) {
    try {
      const data = JSON.parse(rel.body);
      const tag = (data.tag_name || '').replace(/^v/, '');
      if (tag) return tag;
    } catch (_) {}
  }

  // Fallback: /tags endpoint — pick highest semver tag
  const tags = await httpGet(`/repos/${repo}/tags`);
  if (!tags || tags.status !== 200) return null;
  try {
    const list = JSON.parse(tags.body);
    const versions = list
      .map((t) => (t.name || '').replace(/^v/, ''))
      .filter((v) => /^\d+\.\d+\.\d+$/.test(v));
    if (versions.length === 0) return null;
    versions.sort((a, b) => {
      const pa = a.split('.').map(Number);
      const pb = b.split('.').map(Number);
      for (let i = 0; i < 3; i++) {
        if (pa[i] !== pb[i]) return pb[i] - pa[i];
      }
      return 0;
    });
    return versions[0];
  } catch (_) {
    return null;
  }
}

function semverGt(a, b) {
  // Returns true if semver a > semver b
  const parse = (v) => (v || '').split('.').map((n) => parseInt(n, 10) || 0);
  const [aMaj, aMin, aPatch] = parse(a);
  const [bMaj, bMin, bPatch] = parse(b);
  if (aMaj !== bMaj) return aMaj > bMaj;
  if (aMin !== bMin) return aMin > bMin;
  return aPatch > bPatch;
}

async function main() {
  try {
    const raw = await readStdin();
    const input = JSON.parse(raw);
    const cwd = input.cwd || process.cwd();

    const localVersion = readLocalVersion(cwd);
    if (!localVersion) {
      process.exit(0);
    }

    const repo = readUpdateSource(cwd);

    // Check cache first
    let remoteVersion = readCache(cwd);

    if (!remoteVersion) {
      remoteVersion = await fetchLatestVersion(repo);
      if (remoteVersion) {
        writeCache(cwd, remoteVersion);
      }
    }

    if (!remoteVersion) {
      // Offline or fetch failed — silent skip
      process.exit(0);
    }

    if (semverGt(remoteVersion, localVersion)) {
      process.stdout.write(
        `━━ Kairos: nova versão disponível (v${localVersion} → v${remoteVersion}) ━━ Rode @kairos *update para atualizar.\n`
      );
    }

    process.exit(0);
  } catch (_) {
    process.exit(0);
  }
}

main();
