---
task: Call Analyze
responsavel: "@call-analyst"
responsavel_type: agent
atomic_layer: analysis
elicit: false
Entrada: |
  - transcript: conteúdo da transcrição (colar texto, ou "arquivo: {path}") — obrigatório (aceita qualquer ferramenta: Fathom, Fireflies, texto colado manualmente)
  - empresa: nome da empresa — obrigatório (ou inferido da transcrição)
Saida: |
  - analysis: data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-{INSTANCE}-YYYY-MM-DD.md
  - trello_card: card criado/atualizado no board de pipeline
  - followup_draft: rascunho de e-mail de follow-up (incluso na análise)
Checklist:
  - "[ ] Processar transcrição e extrair campos estruturados"
  - "[ ] Determinar estágio do deal com critério explícito"
  - "[ ] Detectar 'não agora' e registrar como nurture com data de recontato"
  - "[ ] Listar dores, objeções e sinais de orçamento/urgência"
  - "[ ] Definir próximos passos com responsável (eu / lead) e data se mencionada"
  - "[ ] Criar/atualizar card no Trello com estágio correto"
  - "[ ] Gerar rascunho de follow-up"
  - "[ ] Salvar análise em data/outputs/sales-pipeline/analyses/"
---

# *analyze — Análise de Call

Processa a transcrição de uma call, extrai dados estruturados do deal, determina o estágio do pipeline, atualiza o Trello e gera um rascunho de follow-up para revisão do usuário.

**CRÍTICO:** O rascunho de follow-up nunca é enviado diretamente — sempre apresentar ao usuário para revisão antes de qualquer envio.

---

## Passo 1 — Extrair campos estruturados da transcrição

Ler a transcrição completa e preencher os campos abaixo. Extrair **apenas** o que foi dito — sem inferências especulativas. Se um campo não foi mencionado, marcar como `não mencionado`.

### Identificação

| Campo | Extraído da transcrição |
|-------|------------------------|
| Empresa | {nome} |
| Contato principal | {nome} — {cargo} |
| Outros participantes | {lista de nomes e cargos, se mencionados} |
| Duração aproximada | {minutos} |

### Sinais Comerciais

**Dores e problemas mencionados** (citar textualmente quando possível):
- {dor 1 — ex: "Não temos visibilidade de quem abriu o e-mail"}
- {dor 2}
- {dor 3 ou "nenhuma dor explícita mencionada"}

**Solução atual** (o que usam hoje para o problema que o produto resolve):
- {ferramenta / processo manual / nada}

**Sinais de orçamento:**
- Budget mencionado: {valor / faixa / "não mencionado"}
- Decision maker na call: {sim — {nome} / não — quem decide: {nome mencionado} / não identificado}
- Processo de aprovação: {descrito / não mencionado}

**Sinais de urgência:**
- Prazo mencionado: {data ou evento / "não mencionado"}
- Motivador de urgência: {por que agora / "não identificado"}

**Objeções levantadas:**
- {objeção 1 — ex: "Preço parece alto para o que estão acostumados a pagar"}
- {objeção 2 ou "nenhuma objeção explícita"}

**Como o produto foi recebido:**
- Reação geral: {entusiasmo / ceticismo / interesse moderado / neutro / negativo}
- Aspecto mais valorizado: {feature ou benefício mencionado positivamente}
- Aspecto questionado: {feature ou ponto que gerou dúvida}

### Próximos Passos Combinados

Lista apenas o que foi **explicitamente combinado** na call:

| Próximo Passo | Responsável | Prazo |
|---------------|-------------|-------|
| {ação 1} | eu / lead | {data ou "sem prazo definido"} |
| {ação 2} | eu / lead | {data ou "sem prazo definido"} |

---

## Passo 2 — Determinar estágio do deal

Classificar em **um** dos estágios abaixo com base em critérios explícitos. Se houver ambiguidade entre nurture e perdido, **HALT e consultar o usuário antes de classificar**.

| Estágio | Critério para classificar aqui |
|---------|-------------------------------|
| **Interesse** | Call realizada, lead demonstrou interesse no produto, próximo passo definido, sem proposta enviada ainda |
| **Proposta** | Lead pediu proposta explicitamente, ou proposta já está em elaboração/enviada, aguardando feedback |
| **Negociação** | Proposta recebida, lead está avaliando termos — pediu ajuste de preço, condições, escopo |
| **Nurture** | Lead tem interesse mas sem timing agora: "em X meses", "precisa de aprovação", "tem contrato vigente", "voltar em {data}" |
| **Fechado** | Deal fechado e confirmado — **HALT obrigatório: confirmar com usuário antes de marcar** |
| **Perdido** | Lead claramente sem interesse ou sem fit identificado — sem margem de nurture |

**Regra para Nurture:** qualquer sinal de "não agora" (e não "não nunca") deve ser classificado como Nurture, não Perdido. Exemplos: "temos contrato até dezembro", "estamos em freeze de budget", "preciso aprovar internamente".

**Estágio determinado:** {estágio}
**Justificativa:** {1-2 frases explicando por que este estágio e não outro}

Se Nurture — registrar:
- Data de recontato sugerida: {data específica mencionada / "3 meses" se sem data}
- Motivo do nurture: {o que mudaria para o lead avançar}

---

## Passo 3 — Criar ou atualizar card no Trello

**Configuração necessária (variáveis de ambiente):**

```
TRELLO_API_KEY    → chave da API do Trello
TRELLO_TOKEN      → token de acesso do usuário
TRELLO_BOARD_ID   → ID do board de pipeline
```

IDs das listas são configurados como:
```
TRELLO_LIST_INTERESSE   → ID da lista "Interesse"
TRELLO_LIST_PROPOSTA    → ID da lista "Proposta"
TRELLO_LIST_NEGOCIACAO  → ID da lista "Negociação"
TRELLO_LIST_NURTURE     → ID da lista "Nurture"
TRELLO_LIST_FECHADO     → ID da lista "Fechado"
TRELLO_LIST_PERDIDO     → ID da lista "Perdido"
```

**Se variáveis não configuradas:** HALT e instruir o usuário a configurar no `.env`.

### Caminho primário — trello-cli

Usar `trello-cli` (ZenoxZX/trello-cli) como interface padrão com o Trello.

**Verificar autenticação antes de operar:**
```bash
trello-cli --check-auth
```
Se falhar → usar fallback REST (seção abaixo).

### 3a — Verificar se card já existe

```bash
trello-cli --get-all-cards $TRELLO_BOARD_ID
```

Buscar no resultado um card cujo nome contenha o nome da empresa. Se encontrado, anotar o `card-id`.

### 3b — Criar ou mover card

**Se card não existe → criar:**
```bash
trello-cli --create-card $TRELLO_LIST_{ESTAGIO} "{empresa} — {contato}" \
  --desc "{descrição abaixo}"
```

**Se card existe → mover para a lista do estágio:**
```bash
trello-cli --move-card {card-id} $TRELLO_LIST_{ESTAGIO}
```

E atualizar a descrição:
```bash
trello-cli --update-card {card-id} --desc "{descrição abaixo}"
```

**Descrição do card (Markdown suportado pelo Trello):**

```
## Deal: {empresa}

**Contato:** {responsavel} — {cargo}
**Call em:** {data de hoje}
**Estágio:** {estágio}

### Dores Identificadas
{dores extraídas da transcrição}

### Próximos Passos
{próximos passos combinados com responsável e prazo}

{se nurture:}
### Recontato
{data de recontato} — {motivo do nurture}

**Análise completa:** data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-{INSTANCE}-{data}.md
```

Confirmar ao usuário após executar:
```
✅ Card Trello {criado/atualizado}: "{empresa} — {contato}" na lista {estágio}
```

### Fallback — REST direto

Usar apenas se `trello-cli` não estiver disponível ou configurado (`--check-auth` falha).

**Verificar se card já existe:**
```
GET https://api.trello.com/1/boards/{TRELLO_BOARD_ID}/cards
    ?key={TRELLO_API_KEY}&token={TRELLO_TOKEN}&fields=id,name,idList
```

**Mover card existente:**
```
PUT https://api.trello.com/1/cards/{cardId}
    ?key={TRELLO_API_KEY}&token={TRELLO_TOKEN}
    Body: { "idList": "{TRELLO_LIST_{ESTAGIO}}" }
```

**Criar card:**
```
POST https://api.trello.com/1/cards
     ?key={TRELLO_API_KEY}&token={TRELLO_TOKEN}
     Body: {
       "idList": "{TRELLO_LIST_{ESTAGIO}}",
       "name": "{empresa} — {contato}",
       "desc": "{descrição acima}"
     }
```

Se a operação Trello falhar (seja via CLI ou REST): registrar o erro, continuar com os demais passos, e notificar o usuário no final para fazer a atualização manual.

---

## Passo 4 — Gerar rascunho de follow-up

Gerar um rascunho de e-mail para envio após a call. **Apresentar ao usuário — nunca enviar.**

O follow-up deve:
- Referenciar um ponto específico da conversa (não ser genérico)
- Resumir o que foi combinado
- Ter CTA claro e único
- Ser curto: máximo 5 parágrafos

**Template base:**

```
Assunto: Re: [assunto original ou "Conversa de hoje — {empresa}"]

Oi {nome do contato},

Obrigado pelo papo de hoje. [Referência específica a algo dito na call — dor, exemplo, dado mencionado pelo lead.]

[Resumo de 1-2 linhas do que foi combinado como próximo passo.]

[Se houver material a enviar: "Segue {o quê} conforme combinamos."]

[CTA único e direto: "Pode me confirmar até {data}?" / "Quando posso te enviar a proposta?" / "Fica de olho no e-mail — mando {o quê} ainda hoje."]

[Assinatura]
```

**Regras de qualidade do follow-up:**
- Primeiro parágrafo deve conter referência específica da call — não pode ser "Obrigado pela conversa"
- CTA deve ser único — não oferecer múltiplas ações no mesmo e-mail
- Se nurture: tom de "a porta está aberta", com data concreta de recontato, sem pressão
- Se perdido: e-mail curto de encerramento educado, deixando caminho aberto

---

## Passo 5 — Salvar análise completa

Salvar em: `data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-{INSTANCE}-{YYYY-MM-DD}.md`

**Estrutura do arquivo de análise:**

```markdown
# Análise de Call — {empresa}

**Data da call:** {data}
**Contato:** {responsavel} — {cargo}
**Analista:** @call-analyst (Cal)
**Estágio:** {estágio determinado}

---

## Sinais Extraídos

### Dores
{lista}

### Solução atual
{o que usam hoje}

### Orçamento e Decisão
- Budget: {info}
- Decision maker: {info}
- Processo de aprovação: {info}

### Urgência
- Prazo: {info}
- Motivador: {info}

### Objeções
{lista}

### Recepção do Produto
- Reação: {reação}
- Mais valorizado: {feature}
- Questionado: {ponto}

---

## Próximos Passos

| Ação | Responsável | Prazo |
|------|-------------|-------|
{tabela}

{se nurture:}
## Recontato
- **Data:** {data}
- **Motivo:** {motivo}

---

## Trello
- Card: {criado/atualizado} — Lista: {estágio}
- Card ID: {id}

---

## Follow-up Draft

{conteúdo do rascunho gerado no Passo 4}

---

*Gerado por @call-analyst em {timestamp}*
```

Confirmar ao usuário:

```
✅ Análise salva: data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-{INSTANCE}-{data}.md

📋 Trello: card {criado/atualizado} na lista "{estágio}"

📧 Follow-up rascunho gerado acima — revise antes de enviar.

{se nurture:}
🔔 Recontato agendado: {data} — {motivo}

— Cal 📞
```

Gerar handoff em `.kairos-core/runtime/handoffs/handoff-call-analyst-to-pre-call-{timestamp}.yaml`:

```yaml
handoff:
  from_agent: "call-analyst"
  to_agent: "pre-call"
  last_command: "analyze"
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    empresa: "{empresa}"
    estagio: "{estágio}"
    analysis_file: "data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-{INSTANCE}-{data}.md"
    trello_card_id: "{id}"
    followup_gerado: true
  next_action: "*brief próximo lead"
```
