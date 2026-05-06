---
task: Pre-Call Brief
responsavel: "@pre-call"
responsavel_type: agent
atomic_layer: analysis
elicit: false
Entrada: |
  - lead: nome ou row_number do lead — obrigatório
  - resposta_email: conteúdo da resposta recebida — opcional (colar diretamente)
  - formulario: dados de formulário preenchido pelo lead — opcional
Saida: |
  - brief: data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-{INSTANCE}-YYYY-MM-DD.md
Checklist:
  - "[ ] Tentar buscar dados do lead via N8N_LEADS_URL (opcional — prosseguir mesmo se ausente/indisponível)"
  - "[ ] Confirmar dados encontrados com o usuário antes de prosseguir (se webhook respondeu)"
  - "[ ] Incorporar conteúdo da resposta de e-mail se disponível"
  - "[ ] Incorporar dados de formulário se disponível"
  - "[ ] Gerar brief com contexto da empresa e perguntas de descoberta calibradas"
  - "[ ] Salvar em data/outputs/sales-pipeline/briefs/"
---

# *brief — Geração de Brief Pré-Call

Gera um documento de preparação para call com lead do pipeline. O brief agrega dados da prospecção (webhook cold-prospecting, quando disponível), a resposta de e-mail recebida e quaisquer dados adicionais fornecidos, entregando contexto suficiente para uma call de descoberta eficaz. O webhook é uma fonte opcional — @pre-call opera normalmente mesmo sem ele.

---

## Passo 1 — Buscar dados do lead

Identificar o lead pelo argumento recebido (`nome` ou `row_number`).

**Fonte: webhook cold-prospecting (opcional)**

```
GET {N8N_LEADS_URL}
Parâmetros: ?identifier={nome_ou_row_number}
```

(`N8N_LEADS_URL` configurada em `.env` — se não estiver definida ou o webhook estiver indisponível, pular para o Passo 2 com dados em branco e informar o usuário.)

Campos esperados na resposta:

| Campo | Descrição |
|-------|-----------|
| `empresa` | Nome da empresa |
| `responsavel` | Nome do contato |
| `cargo` | Cargo do contato |
| `email` | E-mail do contato |
| `cidade` | Cidade da empresa |
| `estado` | Estado |
| `segmento` | Segmento / nicho |
| `capital_social` | Capital social declarado |
| `data_envio` | Data em que o e-mail de prospecção foi enviado |
| `assunto_email` | Assunto do e-mail enviado |
| `status` | Status atual (pendente / enviado / respondido / agendado) |
| `score` | Score do lead (se disponível) |
| `tier` | Tier do lead (se disponível) |

**Se o webhook estiver indisponível ou `N8N_LEADS_URL` não configurada:** informar o usuário e continuar — gerar brief apenas com os dados fornecidos diretamente (resposta de e-mail, formulário, ou dados colados na conversa). Não inventar dados.

**Se nenhum lead for encontrado com o identificador:** exibir ao usuário e aguardar correção ou confirmação para buscar por nome parcial.

---

## Passo 2 — Confirmar dados e coletar contexto adicional

Exibir os dados encontrados de forma resumida:

```
📋 Lead encontrado:
  Empresa: {empresa} ({cidade}/{estado})
  Contato: {responsavel} — {cargo}
  Segmento: {segmento}
  Capital social: {capital_social}
  E-mail enviado em: {data_envio}
  Status atual: {status}
  Score/Tier: {score} / {tier}

Resposta de e-mail disponível? Se sim, cole o conteúdo agora ou confirme que não há.
```

Se o usuário já forneceu `resposta_email` no comando, pular essa pergunta.

---

## Passo 3 — Incorporar interações anteriores

Se `resposta_email` foi fornecido:
- Identificar o tom da resposta (curiosidade, ceticismo, urgência, educado mas frio)
- Extrair sinais comerciais presentes na resposta:
  - Dores mencionadas ou insinuadas
  - Objeções antecipadas
  - Contexto de timing (já tem solução, está buscando, tem prazo)
  - Quem respondeu e o cargo (pode ser diferente do prospectado)
- Anotar o tom para calibrar abordagem na call

Se `formulario` foi fornecido:
- Incorporar campos adicionais relevantes (tamanho da equipe, sistema atual, desafio principal, etc.)

Se nenhuma interação adicional disponível:
- Seguir apenas com dados da prospecção e construir perguntas de abertura mais amplas.

---

## Passo 4 — Gerar o brief

Gerar o documento seguindo a estrutura abaixo. **Usar apenas dados confirmados — nunca especular.**

```markdown
# Brief Pré-Call — {empresa}

**Data da call:** {data de hoje}
**Contato:** {responsavel} — {cargo}
**Empresa:** {empresa} | {cidade}/{estado}
**Segmento:** {segmento}
**Capital social:** {capital_social}

---

## Contexto da Prospecção

**Quando prospectado:** {data_envio}
**Score/Tier:** {score} / {tier}
**Status:** {status}

{se resposta_email disponível:}
**Tom da resposta:** {tom identificado — ex: "receptivo, mencionou dificuldade com X"}

> "{trecho mais relevante da resposta, se houver}"

{se sem resposta:}
**Tipo de engajamento:** Call agendada sem resposta prévia ao e-mail — abordagem de cold call.

---

## Sinais Relevantes

{Lista dos sinais extraídos da resposta ou do perfil — máximo 4 bullets}
- {sinal 1}
- {sinal 2}

---

## Perguntas de Descoberta Sugeridas

{3 a 4 perguntas específicas ao contexto deste lead. Variar entre:}
- **Dor:** "O que motivou vocês a responder?"
- **Processo atual:** "Como vocês lidam com isso hoje?"
- **Decisão:** "Quem mais estaria envolvido nessa avaliação?"
- **Timing:** "Quando vocês precisariam ter algo resolvido?"

1. {pergunta 1 — mais urgente dado o contexto}
2. {pergunta 2}
3. {pergunta 3}
{4. {pergunta 4 — opcional, se houver sinal específico que justifique}}

---

## Pontos de Atenção

{Avisos que o vendedor deve ter em mente — máximo 3}
- {ponto 1 — ex: "Capital social baixo — validar ticket antes de avançar"}
- {ponto 2}
```

**Regras de qualidade do brief:**

- Máximo de 1 página — se não couber em 2 minutos de leitura, está longo demais
- Perguntas devem ser específicas ao lead — proibido perguntas genéricas do tipo "quais são seus desafios?"
- Pontos de atenção só se realmente relevantes — não preencher por obrigação
- Se não há sinal suficiente para gerar perguntas específicas, dizer isso e gerar perguntas de abertura padrão explicitando que são abertura

---

## Passo 5 — Salvar o brief

Salvar em: `data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-{INSTANCE}-{YYYY-MM-DD}.md`

Substituir espaços por hífens no nome da empresa. Ex: `pre-call_brief-Acme-Servicos-2026-04-27.md`

Confirmar ao usuário:
```
✅ Brief gerado: data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-{INSTANCE}-{data}.md

Boa call com {responsavel} da {empresa}.
— Rex 🔍
```

Gerar handoff para @call-analyst em `.kairos-core/runtime/handoffs/handoff-pre-call-to-call-analyst-{timestamp}.yaml`:

```yaml
handoff:
  from_agent: "pre-call"
  to_agent: "call-analyst"
  last_command: "brief"
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    empresa: "{empresa}"
    contato: "{responsavel}"
    brief_file: "data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-{INSTANCE}-{data}.md"
    tom_resposta: "{tom identificado ou 'sem resposta prévia'}"
    score: "{score}"
  next_action: "*analyze após a call"
```
