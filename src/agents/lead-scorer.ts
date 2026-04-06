/**
 * lead-scorer — Pontua e ordena leads por potencial de conversão
 *
 * Sem API. Usa heurísticas sobre capital social, nicho, cidade e situação
 * para gerar uma lista priorizada de quem contatar primeiro.
 *
 * Uso: npx tsx src/agents/lead-scorer.ts
 * Saída: data/reports/scored-leads-YYYY-MM-DD.csv
 */

import "dotenv/config";
import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";

const LEADS_URL =
  process.env.N8N_LEADS_URL ?? "https://n8n.vendoteca.com/webhook/kairos-leads";

// ──────────────────────────────────────────────
// Tipos
// ──────────────────────────────────────────────

interface Lead {
  row_number: number;
  CNPJ: string;
  Nome: string;
  "Nome Fantasia": string;
  Email: string;
  "Atividade Principal": string;
  "Status API": string;
  "Status do Envio": string;
  "Pode disparar": string;
  "Status Geral": string;
  Cidade: string;
  Estado: string;
  "Capital Social": string;
  Situação: string;
}

// ──────────────────────────────────────────────
// Tabela de pontuação
// ──────────────────────────────────────────────

const CAPITAIS = new Set([
  "SAO PAULO", "RIO DE JANEIRO", "BELO HORIZONTE", "SALVADOR", "FORTALEZA",
  "CURITIBA", "MANAUS", "RECIFE", "PORTO ALEGRE", "BELEM", "GOIANIA",
  "FLORIANOPOLIS", "NATAL", "MACEIO", "TERESINA", "JOAO PESSOA",
  "CAMPO GRANDE", "PORTO VELHO", "CUIABA", "MACAPA", "RIO BRANCO",
  "BOA VISTA", "PALMAS", "ARACAJU", "VITORIA",
]);

// Nichos com maior taxa de resposta em serviços de automação
const NICHO_SCORE: Record<string, number> = {
  odont: 30,
  clin: 25,
  medic: 25,
  psico: 20,
  fisiot: 20,
  nutri: 20,
  estet: 15,
  beleza: 15,
  cabel: 10,
  barbear: 10,
  manic: 10,
};

function norm(s: string) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function nichoScore(atividade: string): number {
  const a = norm(atividade);
  for (const [key, pts] of Object.entries(NICHO_SCORE)) {
    if (a.includes(key)) return pts;
  }
  return 5; // outros nichos
}

function capitalScore(capitalStr: string): number {
  const val = parseFloat(String(capitalStr || "0").replace(/[^\d.]/g, ""));
  if (val >= 100_000) return 30;
  if (val >= 50_000) return 20;
  if (val >= 10_000) return 10;
  return 0;
}

function cidadeScore(cidade: string): number {
  return CAPITAIS.has(norm(cidade).toUpperCase()) ? 15 : 0;
}

function situacaoScore(situacao: string): number {
  return norm(situacao).includes("ativa") ? 10 : 0;
}

function score(lead: Lead): number {
  return (
    nichoScore(lead["Atividade Principal"]) +
    capitalScore(lead["Capital Social"]) +
    cidadeScore(lead.Cidade) +
    situacaoScore(lead.Situação)
  );
}

// ──────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────

async function main() {
  console.error("Buscando leads...");
  const res = await fetch(LEADS_URL);
  if (!res.ok) throw new Error(`Webhook retornou ${res.status}`);
  const { leads } = (await res.json()) as { leads: Lead[] };
  console.error(`${leads.length.toLocaleString("pt-BR")} leads carregados.`);

  // Filtra apenas prontos para disparar e ainda não enviados
  const pendentes = leads.filter(
    (l) =>
      l["Pode disparar"] === "SIM" &&
      (!l["Status do Envio"] || l["Status do Envio"] === "NÃO ENVIADO")
  );
  console.error(`${pendentes.length.toLocaleString("pt-BR")} pendentes de envio.`);

  // Pontua e ordena
  const scored = pendentes
    .map((l) => ({ ...l, _score: score(l) }))
    .sort((a, b) => b._score - a._score);

  // Gera CSV
  const header = "row_number,score,CNPJ,Nome,Email,Atividade Principal,Cidade,Estado,Capital Social";
  const rows = scored.map((l) =>
    [
      l.row_number,
      l._score,
      l.CNPJ,
      `"${String(l["Nome Fantasia"] || l.Nome || "").replace(/"/g, '""')}"`,
      l.Email,
      `"${String(l["Atividade Principal"] || "").replace(/"/g, '""')}"`,
      l.Cidade,
      l.Estado,
      l["Capital Social"],
    ].join(",")
  );
  const csv = [header, ...rows].join("\n");

  const dateStr = new Date().toISOString().slice(0, 10);
  const dir = join(process.cwd(), "data", "reports");
  mkdirSync(dir, { recursive: true });
  const outPath = join(dir, `scored-leads-${dateStr}.csv`);
  writeFileSync(outPath, csv, "utf-8");

  // Resumo no terminal
  const dist = [100, 75, 50, 25, 0].map((threshold) => ({
    threshold,
    count: scored.filter((l) => l._score >= threshold).length,
  }));

  console.error(`\nDistribuição de score:`);
  for (const { threshold, count } of dist) {
    console.error(`  >= ${String(threshold).padStart(3)} pts: ${count.toLocaleString("pt-BR")} leads`);
  }
  console.error(`\nTop 5 leads:`);
  for (const l of scored.slice(0, 5)) {
    console.error(`  [${l._score}] ${(l["Nome Fantasia"] || l.Nome || "?").slice(0, 40)} — ${l.Cidade}/${l.Estado}`);
  }
  console.error(`\nSalvo em: ${outPath}`);
}

main().catch((err) => {
  console.error("Erro:", err.message);
  process.exit(1);
});
