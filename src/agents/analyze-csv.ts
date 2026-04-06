/**
 * Agente: Analisador de CSV
 * Uso: npx tsx src/agents/analyze-csv.ts data/arquivo.csv "Qual a pergunta?"
 */

import "dotenv/config";
import { readFileSync } from "fs";
import { run } from "../tools/claude.js";

const SYSTEM_PROMPT = `Você é um analista de dados especialista.
Recebe o conteúdo de um arquivo CSV e responde perguntas sobre ele com precisão.
Identifique padrões, anomalias e insights relevantes.
Responda em português (Brasil), de forma clara e direta.`;

async function main() {
  const [, , csvPath, question] = process.argv;

  if (!csvPath || !question) {
    console.error("Uso: npx tsx src/agents/analyze-csv.ts <arquivo.csv> <pergunta>");
    process.exit(1);
  }

  const csvContent = readFileSync(csvPath, "utf-8");
  const prompt = `Arquivo CSV:\n\`\`\`\n${csvContent}\n\`\`\`\n\nPergunta: ${question}`;

  console.log("Analisando...\n");
  const result = await run(prompt, SYSTEM_PROMPT);

  if (!result.success) {
    console.error("Erro:", result.error);
    process.exit(1);
  }

  console.log(result.output);
}

main();
