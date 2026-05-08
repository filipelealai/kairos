#!/usr/bin/env node
'use strict';

/**
 * kairos-powershell-encoding-guard.cjs
 *
 * Hook de PreToolUse do Kairos.
 * Lembra o agente de tratar UTF-8 explicitamente ao operar PowerShell/Windows.
 *
 * Stdin: { tool_name, tool_input, cwd, ... }
 * Stdout: XML com orientação curta quando houver risco de encoding.
 */

const HOOK_TIMEOUT_MS = 3000;

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

function stringifyToolInput(toolInput) {
  try {
    return JSON.stringify(toolInput || {});
  } catch (_) {
    return '';
  }
}

function shouldWarn(input) {
  const toolName = input.tool_name || '';
  const toolInput = input.tool_input || {};
  const command = String(toolInput.command || toolInput.cmd || '');
  const filePath = String(toolInput.file_path || toolInput.path || '');
  const haystack = `${toolName}\n${command}\n${filePath}\n${stringifyToolInput(toolInput)}`;

  if (process.platform === 'win32') return true;
  if (/\b(powershell|pwsh|powershell\.exe|pwsh\.exe)\b/i.test(haystack)) return true;
  if (/\.ps1\b/i.test(haystack)) return true;
  if (/\b(Set-Content|Get-Content|Out-File|ConvertTo-Json|Invoke-WebRequest)\b/i.test(haystack)) return true;

  return false;
}

async function main() {
  try {
    const raw = await readStdin();
    const input = JSON.parse(raw);

    if (!shouldWarn(input)) {
      process.exit(0);
    }

    process.stdout.write(`<kairos-powershell-encoding-guard>
PowerShell/Windows encoding guard:
- Windows PowerShell 5.1 does not reliably treat UTF-8 without BOM as UTF-8.
- Publish executable .ps1 files as UTF-8 with BOM when they may run in Windows PowerShell 5.1.
- Do not rely on Get-Content/Set-Content/Out-File default encodings for user files.
- Prefer explicit .NET UTF-8 file APIs:
  [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
- For Invoke-WebRequest in Windows PowerShell 5.1, use -UseBasicParsing when reading .Content.
- For JSON formatting in PowerShell 5.1, avoid depending on ConvertTo-Json pretty spacing if formatting matters.
</kairos-powershell-encoding-guard>`);
    process.exit(0);
  } catch (_) {
    process.exit(0);
  }
}

main();
