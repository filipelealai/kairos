#!/usr/bin/env node
'use strict';

/**
 * kairos-precompact.cjs
 *
 * Hook de PreCompact do Kairos.
 * Executa antes da compactação de contexto pelo Claude Code.
 * Injeta um digest de estado atual do framework para preservar contexto essencial.
 *
 * Stdin: { session_id, transcript_path, cwd, hook_event_name, trigger }
 * Stdout: XML com digest (Claude inclui no contexto antes de compactar)
 */

const HOOK_TIMEOUT_MS = 9000;
const fs = require('fs');
const path = require('path');

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

async function main() {
  try {
    const raw = await readStdin();
    const input = JSON.parse(raw);
    const cwd = input.cwd || process.cwd();

    const lines = [];

    // 1. Versão atual do Kairos
    try {
      const configPath = path.join(cwd, '.kairos-core/core-config.yaml');
      const config = fs.readFileSync(configPath, 'utf8');
      const versionMatch = config.match(/^version:\s*(.+)/m);
      if (versionMatch) {
        lines.push(`kairos_version: ${versionMatch[1].trim()}`);
      }
    } catch (_) {}

    // 2. Stories abertas (não Done)
    try {
      const storiesDir = path.join(cwd, 'docs/stories');
      const files = fs.readdirSync(storiesDir)
        .filter(f => f.endsWith('.story.md'))
        .sort();
      const open = [];
      for (const f of files) {
        const content = fs.readFileSync(path.join(storiesDir, f), 'utf8');
        const statusMatch = content.match(/\*\*Status:\*\*\s*(.+)/);
        if (!statusMatch) continue;
        const status = statusMatch[1].trim();
        if (['Draft', 'In Progress', 'In Review'].includes(status)) {
          const titleMatch = content.match(/^#\s+(.+)/m);
          const title = titleMatch ? titleMatch[1].replace(/^Story \S+\s*—\s*/, '') : f;
          open.push(`  - ${f.replace('.story.md', '')} [${status}]: ${title.trim()}`);
        }
      }
      if (open.length > 0) {
        lines.push(`open_stories:\n${open.join('\n')}`);
      }
    } catch (_) {}

    // 3. Último gate de review
    try {
      const gatesDir = path.join(cwd, 'docs/qa/gates');
      const gates = fs.readdirSync(gatesDir)
        .filter(f => f.endsWith('.yaml'))
        .sort()
        .reverse();
      if (gates.length > 0) {
        const gateContent = fs.readFileSync(path.join(gatesDir, gates[0]), 'utf8');
        const verdict = (gateContent.match(/verdict:\s*(.+)/) || [])[1];
        const story = (gateContent.match(/\bstory:\s*(.+)/) || [])[1];
        const score = (gateContent.match(/quality_score:\s*(.+)/) || [])[1];
        if (verdict && story) {
          lines.push(`last_gate: story=${story.trim()} verdict=${verdict.trim()}${score ? ` score=${score.trim()}` : ''}`);
        }
      }
    } catch (_) {}

    // 4. Handoffs pendentes (não consumidos)
    try {
      const handoffsDir = path.join(cwd, '.kairos-core/runtime/handoffs');
      const handoffFiles = fs.readdirSync(handoffsDir)
        .filter(f => f.endsWith('.yaml'))
        .sort()
        .reverse()
        .slice(0, 3);
      const pending = [];
      for (const f of handoffFiles) {
        const content = fs.readFileSync(path.join(handoffsDir, f), 'utf8');
        if (!content.includes('consumed: true')) {
          const fromMatch = content.match(/from_agent:\s*(.+)/);
          const toMatch = content.match(/to_agent:\s*(.+)/);
          if (fromMatch && toMatch) {
            pending.push(`  - ${fromMatch[1].trim()} → ${toMatch[1].trim()}`);
          }
        }
      }
      if (pending.length > 0) {
        lines.push(`pending_handoffs:\n${pending.join('\n')}`);
      }
    } catch (_) {}

    if (lines.length === 0) {
      process.exit(0);
    }

    const digest = `<kairos-session-digest>
# Kairos — Estado do Framework (pre-compaction)
${lines.join('\n')}
</kairos-session-digest>`;

    process.stdout.write(digest);
    process.exit(0);
  } catch (_) {
    process.exit(0);
  }
}

main();
