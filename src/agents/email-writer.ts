/**
 * email-writer — Gera e-mails personalizados por empresa usando Claude
 *
 * Pega os N leads melhor pontuados (ou os primeiros pendentes) e gera
 * um e-mail único por empresa — não o template genérico do n8n.
 * Salva JSON pronto para ser importado de volta ao n8n ou enviado direto.
 *
 * Uso:
 *   npx tsx src/agents/email-writer.ts @filipe       # 10 leads com persona Filipe
 *   npx tsx src/agents/email-writer.ts @filipe 50    # 50 leads
 *
 * Saída: data/outputs/cold-prospecting/emails/email-writer_emails-YYYY-MM-DD.json
 */

import "dotenv/config";
import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";
import { chat } from "../tools/claude.js";

const LEADS_URL =
  process.env.N8N_LEADS_URL ?? "https://n8n.vendoteca.com/webhook/kairos-leads";

const LIMIT = parseInt(process.argv[2] ?? "10", 10);

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
  "Status do Envio": string;
  "Pode disparar": string;
  Cidade: string;
  Estado: string;
  "Capital Social": string;
  Situação: string;
}

interface EmailGerado {
  row_number: number;
  cnpj: string;
  email: string;
  nome: string;
  assunto: string;
  corpo: string;
}

// ──────────────────────────────────────────────
// Geração de e-mail
// ──────────────────────────────────────────────

function cleanName(lead: Lead): string {
  let nome = lead["Nome Fantasia"] || lead.Nome || "sua empresa";
  nome = nome
    .replace(/\b\d{2,3}\.\d{3}\.\d{3}(?:\/\d{4})?-?\d{2}\b/g, "")
    .replace(/\b(ltda|me|epp|eireli|s\.a\.?|s\/a|mei)\b/gi, "")
    .replace(/\s+/g, " ")
    .trim();
  if (nome.length < 2) return "sua empresa";
  return nome
    .toLowerCase()
    .split(" ")
    .map((w) => (["de", "da", "do", "dos", "das", "e", "em"].includes(w) ? w : w[0].toUpperCase() + w.slice(1)))
    .join(" ");
}

async function generateEmail(lead: Lead): Promise<{ assunto: string; corpo: string }> {
  const nome = cleanName(lead);
  const cidade = lead.Cidade
    ? lead.Cidade.charAt(0).toUpperCase() + lead.Cidade.slice(1).toLowerCase()
    : null;

  const user = `
Escreva um e-mail de prospecção para a empresa abaixo.

Empresa: ${nome}
Atividade: ${lead["Atividade Principal"]}
${cidade ? `Cidade: ${cidade}/${lead.Estado}` : ""}
${lead["Capital Social"] ? `Capital social: R$ ${parseFloat(lead["Capital Social"]).toLocaleString("pt-BR")}` : ""}

Responda APENAS com JSON no formato:
{"assunto": "...", "corpo": "...html..."}

O assunto deve ser curto (max 60 chars), específico para o setor, sem "RE:" ou "FWD:".
O corpo deve ser HTML com tags <p>.
`.trim();

  const raw = await chat(
    [{ role: "user", content: user }],
    { maxTokens: 1024 }
  );

  const match = raw.match(/\{[\s\S]+\}/);
  if (!match) throw new Error(`Resposta inválida: ${raw.slice(0, 200)}`);

  return JSON.parse(match[0]) as { assunto: string; corpo: string };
}

// ──────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────

async function main() {
  console.error("Buscando leads...");
  const res = await fetch(LEADS_URL);
  if (!res.ok) throw new Error(`Webhook retornou ${res.status}`);
  const { leads } = (await res.json()) as { leads: Lead[] };

  const pendentes = leads
    .filter(
      (l) =>
        l["Pode disparar"] === "SIM" &&
        l.Email?.trim() &&
        (!l["Status do Envio"] || l["Status do Envio"] === "NÃO ENVIADO")
    )
    .slice(0, LIMIT);

  console.error(`Gerando e-mails para ${pendentes.length} leads...\n`);

  const emails: EmailGerado[] = [];
  let ok = 0;
  let fail = 0;

  for (const lead of pendentes) {
    const nome = cleanName(lead);
    process.stderr.write(`  [${ok + fail + 1}/${pendentes.length}] ${nome.slice(0, 40)}... `);
    try {
      const { assunto, corpo } = await generateEmail(lead);
      emails.push({
        row_number: lead.row_number,
        cnpj: lead.CNPJ,
        email: lead.Email,
        nome,
        assunto,
        corpo,
      });
      ok++;
      process.stderr.write("✓\n");
    } catch (err) {
      fail++;
      process.stderr.write(`✗ ${err instanceof Error ? err.message : err}\n`);
    }

    // Pausa para não estressar a API
    await new Promise((r) => setTimeout(r, 500));
  }

  const dateStr = new Date().toISOString().slice(0, 10);
  const dir = join(process.cwd(), "data", "outputs", "cold-prospecting", "emails");
  mkdirSync(dir, { recursive: true });
  const outPath = join(dir, `email-writer_emails-${dateStr}.json`);
  writeFileSync(outPath, JSON.stringify(emails, null, 2), "utf-8");

  console.error(`\n${ok} e-mails gerados, ${fail} falhas.`);
  console.error(`Salvo em: ${outPath}`);

  // Preview do primeiro
  if (emails[0]) {
    console.error("\n── Preview do primeiro e-mail ──────────────────────────");
    console.error(`Para:    ${emails[0].email}`);
    console.error(`Assunto: ${emails[0].assunto}`);
    console.error(`Corpo:   ${emails[0].corpo.replace(/<[^>]+>/g, "").trim().slice(0, 200)}...`);
  }
}

main().catch((err) => {
  console.error("Erro:", err.message);
  process.exit(1);
});
