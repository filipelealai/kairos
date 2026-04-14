#!/usr/bin/env node
'use strict';

/**
 * kairos-code-intel.cjs
 *
 * Hook de PreToolUse do Kairos (Write | Edit).
 * Injeta contexto relevante baseado no caminho do arquivo sendo editado.
 * Sem dependências externas — usa grep/leitura de arquivo simples.
 *
 * Stdin: { tool_name, tool_input: { file_path, ... }, cwd, ... }
 * Stdout: XML com contexto (Claude usa para melhor completar a edição)
 */

const HOOK_TIMEOUT_MS = 4000;
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

function relativePath(absPath, cwd) {
  return absPath.startsWith(cwd + '/')
    ? absPath.slice(cwd.length + 1)
    : absPath;
}

function safeRead(filePath, maxLines) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    if (!maxLines) return content;
    return content.split('\n').slice(0, maxLines).join('\n');
  } catch (_) {
    return null;
  }
}

function firstMatchInDir(dirPath, ext, excludeFile) {
  try {
    const files = fs.readdirSync(dirPath)
      .filter(f => f.endsWith(ext) && (!excludeFile || !excludeFile.endsWith(f)))
      .sort();
    return files.length > 0 ? path.join(dirPath, files[0]) : null;
  } catch (_) {
    return null;
  }
}

async function main() {
  try {
    const raw = await readStdin();
    const input = JSON.parse(raw);

    const toolName = input.tool_name || '';
    if (!['Write', 'Edit'].includes(toolName)) {
      process.exit(0);
    }

    const filePath = (input.tool_input || {}).file_path || '';
    if (!filePath) process.exit(0);

    const cwd = input.cwd || process.cwd();
    const rel = relativePath(filePath, cwd);

    let label = null;
    let content = null;

    // --- src/agents/ → exportações do claude.ts (interface da AI) ---
    if (rel.startsWith('src/agents/')) {
      const claudePath = path.join(cwd, 'src/tools/claude.ts');
      const src = safeRead(claudePath);
      if (src) {
        const exports = src.match(/^export (async )?function \w+[^{]+/gm) || [];
        if (exports.length > 0) {
          label = 'src/tools/claude.ts — exported functions';
          content = exports.join('\n');
        }
      }
    }

    // --- .kairos-core/tasks/ → primeiras linhas de uma task existente (formato) ---
    else if (rel.startsWith('.kairos-core/tasks/')) {
      const tasksDir = path.join(cwd, '.kairos-core/tasks');
      const samplePath = firstMatchInDir(tasksDir, '.md', filePath);
      if (samplePath) {
        const sample = safeRead(samplePath, 20);
        if (sample) {
          label = `task format reference: ${path.basename(samplePath)}`;
          content = sample;
        }
      }
    }

    // --- .claude/commands/kairos/agents/ → activation-instructions format ---
    else if (rel.startsWith('.claude/commands/kairos/agents/')) {
      const standardsPath = path.join(cwd, 'docs/framework/agent-standards.md');
      const standards = safeRead(standardsPath);
      if (standards) {
        // Extrai o bloco YAML de formato da persona (entre primeiro ```yaml e ```)
        const match = standards.match(/```yaml\n([\s\S]+?)```/);
        if (match) {
          label = 'agent-standards.md — persona YAML format';
          content = match[1].slice(0, 1000);
        }
      }
    }

    // --- .claude/rules/ → formato de uma rule existente ---
    else if (rel.startsWith('.claude/rules/')) {
      const rulesDir = path.join(cwd, '.claude/rules');
      const samplePath = firstMatchInDir(rulesDir, '.md', filePath);
      if (samplePath) {
        const sample = safeRead(samplePath, 12);
        if (sample) {
          label = `rule format reference: ${path.basename(samplePath)}`;
          content = sample;
        }
      }
    }

    // --- squads/*/ → squad.yaml format ---
    else if (rel.startsWith('squads/')) {
      const templatePath = path.join(cwd, '.kairos-core/templates/squad-template/squad.yaml');
      const template = safeRead(templatePath, 20);
      if (template) {
        label = 'squad.yaml template format';
        content = template;
      }
    }

    // --- docs/stories/ → story template ---
    else if (rel.startsWith('docs/stories/') && rel.endsWith('.story.md')) {
      const templatePath = path.join(cwd, '.kairos-core/templates/story-template.md');
      const template = safeRead(templatePath);
      if (template) {
        label = 'story-template.md';
        content = template;
      }
    }

    if (!label || !content) {
      process.exit(0);
    }

    const output = `<kairos-code-intel>
<!-- ${label} -->
${content.trimEnd()}
</kairos-code-intel>`;

    process.stdout.write(output);
    process.exit(0);
  } catch (_) {
    process.exit(0);
  }
}

main();
