/**
 * niche-classifier — Classifica atividades que escapam das keywords do n8n
 *
 * Pega as atividades sem nicho definido (o fallback genérico) e usa Claude
 * para mapeá-las a um dos nichos existentes ou sugerir novos.
 * Útil para expandir a cobertura antes de uma rodada de envio.
 *
 * Uso: npx tsx src/agents/niche-classifier.ts
 * Saída: data/outputs/cold-prospecting/reports/niche-classifier_niche-map-YYYY-MM-DD.json
 */

import "dotenv/config";
import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";
import { ask } from "../tools/claude.js";

const LEADS_URL =
  process.env.N8N_LEADS_URL ?? "https://n8n.vendoteca.com/webhook/kairos-leads";

// Nichos existentes no workflow de prospecção
const NICHOS_EXISTENTES = [
  "saude_clinicas",
  "estetica_bem_estar",
  "eventos_fotografia",
  "educacao_cursos",
  "manutencao_tecnica",
  "restaurantes_alimentacao",
  "construcao_engenharia",
  "advocacia",
  "fallback",
] as const;

type Nicho = (typeof NICHOS_EXISTENTES)[number];

interface LeadRaw {
  "Atividade Principal": string;
  "Pode disparar": string;
  "Status do Envio": string;
}

// Keywords que já têm cobertura no n8n — atividades com elas são ignoradas
const KEYWORDS_COBERTAS = [
  "odont", "dent", "clin", "saude", "medic", "psico", "terap", "fisiot", "nutri",
  "estet", "beleza", "salao", "cabel", "barbear", "manic", "sobrancel", "depil", "maqui", "spa",
  "event", "festa", "fotograf", "film", "dj", "decor", "cerimonial", "buffet", "casament",
  "ensino", "educ", "escola", "curso", "idioma", "trein", "instrut", "aula",
  "manut", "mecanic", "oficina", "reparo", "eletric", "instal", "limpeza", "climat", "assist",
  "restaur", "lanch", "bebid", "bar", "aliment", "refeic", "pizz", "hamburg",
  "constr", "obra", "engenh", "reform", "arquitet", "empreit",
  "advoc", "jurid", "direito",
];

function norm(s: string) {
  return String(s || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function temCobertura(atividade: string): boolean {
  const a = norm(atividade);
  return KEYWORDS_COBERTAS.some((kw) => a.includes(kw));
}

async function classifyBatch(atividades: string[]): Promise<Record<string, Nicho>> {
  const lista = atividades.map((a, i) => `${i + 1}. ${a}`).join("\n");

  const prompt = `
Você é um especialista em segmentação B2B. Classifique cada atividade empresarial abaixo em um dos nichos:

- saude_clinicas: clínicas, consultórios, hospitais, laboratórios, farmácias, veterinários
- estetica_bem_estar: beleza, estética, salões, spas, barbearias
- eventos_fotografia: eventos, festas, casamentos, fotografia, filmagem, decoração
- educacao_cursos: escolas, cursos, idiomas, treinamentos, coaches
- manutencao_tecnica: manutenção, reparos, instalações, eletricistas, encanadores, TI
- restaurantes_alimentacao: restaurantes, lanchonetes, delivery, bares, docerias
- construcao_engenharia: construção, reformas, engenharia, arquitetura, imobiliárias
- advocacia: escritórios jurídicos, contabilidade, consultoria jurídica
- fallback: não se encaixa claramente em nenhum dos acima

Atividades:
${lista}

Responda APENAS com JSON no formato:
{"1": "nicho", "2": "nicho", ...}
`.trim();

  const raw = await ask(prompt, { maxTokens: 1024 });

  // Extrai o JSON da resposta
  const match = raw.match(/\{[\s\S]+\}/);
  if (!match) throw new Error(`Claude não retornou JSON válido: ${raw.slice(0, 200)}`);

  const parsed = JSON.parse(match[0]) as Record<string, string>;

  // Mapeia de volta para as atividades originais
  const result: Record<string, Nicho> = {};
  for (const [idx, nicho] of Object.entries(parsed)) {
    const atividade = atividades[parseInt(idx) - 1];
    if (atividade) {
      result[atividade] = (NICHOS_EXISTENTES.includes(nicho as Nicho) ? nicho : "fallback") as Nicho;
    }
  }
  return result;
}

async function main() {
  console.error("Buscando leads...");
  const res = await fetch(LEADS_URL);
  if (!res.ok) throw new Error(`Webhook retornou ${res.status}`);
  const { leads } = (await res.json()) as { leads: LeadRaw[] };
  console.error(`${leads.length.toLocaleString("pt-BR")} leads carregados.`);

  // Pega atividades únicas sem cobertura
  const semCobertura = [
    ...new Set(
      leads
        .filter(
          (l) =>
            l["Pode disparar"] === "SIM" &&
            l["Atividade Principal"] &&
            !temCobertura(l["Atividade Principal"])
        )
        .map((l) => l["Atividade Principal"])
    ),
  ];

  console.error(`${semCobertura.length} atividades únicas sem cobertura de nicho.`);

  if (semCobertura.length === 0) {
    console.error("Nenhuma atividade para classificar.");
    return;
  }

  // Classifica em batches de 30
  const BATCH = 30;
  const nichoMap: Record<string, Nicho> = {};
  for (let i = 0; i < semCobertura.length; i += BATCH) {
    const batch = semCobertura.slice(i, i + BATCH);
    const pct = Math.round(((i + batch.length) / semCobertura.length) * 100);
    console.error(`Classificando batch ${Math.floor(i / BATCH) + 1}... (${pct}%)`);
    const result = await classifyBatch(batch);
    Object.assign(nichoMap, result);
  }

  // Agrupa por nicho para visualização
  const porNicho: Record<string, string[]> = {};
  for (const [atividade, nicho] of Object.entries(nichoMap)) {
    porNicho[nicho] = porNicho[nicho] ?? [];
    porNicho[nicho].push(atividade);
  }

  // Conta leads afetados por nicho
  const contagemLeads: Record<string, number> = {};
  for (const lead of leads) {
    const nicho = nichoMap[lead["Atividade Principal"]];
    if (nicho) {
      contagemLeads[nicho] = (contagemLeads[nicho] ?? 0) + 1;
    }
  }

  // Salva resultado
  const output = {
    geradoEm: new Date().toISOString(),
    totalAtividades: semCobertura.length,
    nichoMap,
    porNicho,
    contagemLeads,
  };

  const dateStr = new Date().toISOString().slice(0, 10);
  const dir = join(process.cwd(), "data", "outputs", "cold-prospecting", "reports");
  mkdirSync(dir, { recursive: true });
  const outPath = join(dir, `niche-classifier_niche-map-${dateStr}.json`);
  writeFileSync(outPath, JSON.stringify(output, null, 2), "utf-8");

  // Resumo
  console.error("\nDistribuição por nicho:");
  for (const [nicho, atividades] of Object.entries(porNicho).sort(
    (a, b) => b[1].length - a[1].length
  )) {
    const leads = contagemLeads[nicho] ?? 0;
    console.error(`  ${nicho.padEnd(25)} ${String(atividades.length).padStart(3)} atividades | ${leads} leads`);
  }
  console.error(`\nSalvo em: ${outPath}`);
}

main().catch((err) => {
  console.error("Erro:", err.message);
  process.exit(1);
});
