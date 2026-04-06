/**
 * campaign-analyst — Analisa os resultados da campanha de prospecção
 *
 * Busca os leads via webhook do n8n e imprime métricas em Markdown.
 *
 * Uso: npx tsx src/agents/campaign-analyst.ts
 */

import "dotenv/config";
import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";

const LEADS_URL =
  process.env.N8N_LEADS_URL ?? "https://n8n.vendoteca.com/webhook/kairos-leads";

// ──────────────────────────────────────────────
// 1. Busca leads
// ──────────────────────────────────────────────

interface Lead {
  row_number: number;
  CNPJ: string;
  Nome: string;
  Email: string;
  "Atividade Principal": string;
  "Status API": string;
  "Status do Envio": string;
  "Pode disparar": string;
  "Status Geral": string;
  Cidade: string;
  Estado: string;
  "Capital Social": string;
}

async function fetchLeads(): Promise<Lead[]> {
  const res = await fetch(LEADS_URL);
  if (!res.ok) throw new Error(`Webhook retornou ${res.status}`);
  const data = (await res.json()) as { leads: Lead[] };
  return data.leads;
}

// ──────────────────────────────────────────────
// 2. Monta estatísticas sem enviar tudo ao Claude
// ──────────────────────────────────────────────

function buildStats(leads: Lead[]) {
  const total = leads.length;

  // Status API
  const byStatusApi = groupCount(leads, (l) => l["Status API"] || "PENDENTE");

  // Status de envio
  const byEnvio = groupCount(
    leads,
    (l) => l["Status do Envio"] || "NÃO ENVIADO"
  );

  // Pode disparar
  const podeDisparar = leads.filter((l) => l["Pode disparar"] === "SIM").length;

  // Cobertura de e-mail por estado (top 10)
  const comEmail = leads.filter(
    (l) => l.Email && l.Email.trim() !== "" && l["Status API"] === "OK"
  );
  const byEstado = groupCount(comEmail, (l) => l.Estado || "?");
  const topEstados = Object.entries(byEstado)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  // Atividades mais comuns entre leads com e-mail (top 15)
  const topAtividades = Object.entries(
    groupCount(comEmail, (l) => l["Atividade Principal"]?.slice(0, 60) || "?")
  )
    .sort((a, b) => b[1] - a[1])
    .slice(0, 15);

  // Leads enviados por estado (top 10)
  const enviados = leads.filter((l) => l["Status do Envio"] === "ENVIADO");
  const enviadosByEstado = groupCount(enviados, (l) => l.Estado || "?");
  const topEnviadosEstado = Object.entries(enviadosByEstado)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  // Erros por estado
  const erros = leads.filter((l) => l["Status do Envio"] === "ERRO");

  return {
    total,
    byStatusApi,
    byEnvio,
    podeDisparar,
    comEmail: comEmail.length,
    semEmail: total - comEmail.length,
    topEstados,
    topAtividades,
    enviados: enviados.length,
    erros: erros.length,
    topEnviadosEstado,
  };
}

function groupCount<T>(arr: T[], key: (item: T) => string): Record<string, number> {
  return arr.reduce<Record<string, number>>((acc, item) => {
    const k = key(item);
    acc[k] = (acc[k] ?? 0) + 1;
    return acc;
  }, {});
}

// ──────────────────────────────────────────────
// 3. Formata e imprime relatório
// ──────────────────────────────────────────────

function pct(part: number, total: number) {
  return total === 0 ? "0%" : `${((part / total) * 100).toFixed(1)}%`;
}

function table(rows: [string, number][], total?: number): string {
  const maxLabel = Math.max(...rows.map(([k]) => k.length), 10);
  return rows
    .map(([k, v]) => {
      const bar = total ? ` (${pct(v, total)})` : "";
      return `  ${k.padEnd(maxLabel)}  ${v.toLocaleString("pt-BR")}${bar}`;
    })
    .join("\n");
}

function printReport(stats: ReturnType<typeof buildStats>): string {
  const sep = "─".repeat(56);

  const lines = [
    `# Relatório de Campanha — ${new Date().toLocaleDateString("pt-BR")}`,
    "",
    `## Visão Geral`,
    "",
    `| Métrica                        | Valor                          |`,
    `|-------------------------------|-------------------------------|`,
    `| Total de leads na base        | ${stats.total.toLocaleString("pt-BR").padStart(7)}                      |`,
    `| Com e-mail válido             | ${stats.comEmail.toLocaleString("pt-BR").padStart(7)} (${pct(stats.comEmail, stats.total)})              |`,
    `| Sem e-mail / não encontrado   | ${stats.semEmail.toLocaleString("pt-BR").padStart(7)} (${pct(stats.semEmail, stats.total)})              |`,
    `| Prontos para disparar (SIM)   | ${stats.podeDisparar.toLocaleString("pt-BR").padStart(7)} (${pct(stats.podeDisparar, stats.total)})              |`,
    `| E-mails enviados              | ${stats.enviados.toLocaleString("pt-BR").padStart(7)} (${pct(stats.enviados, stats.comEmail)} dos com e-mail)  |`,
    `| Erros de envio                | ${stats.erros.toLocaleString("pt-BR").padStart(7)} (${pct(stats.erros, stats.enviados + stats.erros)} dos tentados)      |`,
    "",
    sep,
    "## Status da API de Scrapping",
    "",
    table(
      Object.entries(stats.byStatusApi).sort((a, b) => b[1] - a[1]) as [string, number][],
      stats.total
    ),
    "",
    sep,
    "## Status de Envio",
    "",
    table(
      Object.entries(stats.byEnvio).sort((a, b) => b[1] - a[1]) as [string, number][],
      stats.total
    ),
    "",
    sep,
    "## Top 10 Estados — E-mails Válidos",
    "",
    table(stats.topEstados as [string, number][], stats.comEmail),
    "",
    sep,
    "## Top 10 Estados — E-mails Enviados",
    "",
    table(stats.topEnviadosEstado as [string, number][], stats.enviados),
    "",
    sep,
    "## Top 15 Atividades com E-mail Disponível",
    "",
    table(stats.topAtividades as [string, number][], stats.comEmail),
  ];

  return lines.join("\n");
}

// ──────────────────────────────────────────────
// 4. Main
// ──────────────────────────────────────────────

async function main() {
  console.error("Buscando leads...");
  const leads = await fetchLeads();
  console.error(`${leads.length.toLocaleString("pt-BR")} leads carregados.\n`);

  const stats = buildStats(leads);
  const report = printReport(stats);

  const dateStr = new Date().toISOString().slice(0, 10);
  const dir = join(process.cwd(), "data", "reports");
  mkdirSync(dir, { recursive: true });
  const outPath = join(dir, `campaign-${dateStr}.md`);
  writeFileSync(outPath, report, "utf-8");

  console.error(`Relatório salvo em: ${outPath}`);
  console.log(report);
}

main().catch((err) => {
  console.error("Erro:", err.message);
  process.exit(1);
});
