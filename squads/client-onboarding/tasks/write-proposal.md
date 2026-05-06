---
task: Write Proposal
responsavel: "@proposal-writer"
responsavel_type: agent
atomic_layer: generation
elicit: false
Entrada: |
  - brief: path do brief estruturado ou contexto colado — obrigatório
  - empresa: nome da empresa cliente — obrigatório
Saida: |
  - proposta: data/outputs/client-onboarding/proposals/proposal-writer_proposal-{empresa}-{INSTANCE}-YYYY-MM-DD.md
Checklist:
  - "[ ] Carregar brief estruturado"
  - "[ ] Carregar template de proposta de squads/client-onboarding/templates/proposal/"
  - "[ ] Adaptar cada seção do template ao contexto do cliente"
  - "[ ] Marcar com [REVISAR] campos que dependem de decisão humana"
  - "[ ] Verificar consistência: escopo, entregáveis, investimento, prazo"
  - "[ ] Salvar proposta em data/outputs/client-onboarding/proposals/"
  - "[ ] Gerar handoff para contract-writer se aplicável"
---

# *write — Geração de Proposta Comercial

## Protocolo de Uso dos Templates

Os templates em `squads/client-onboarding/templates/proposal/` são a base obrigatória.
Cada arquivo é uma seção independente — a proposta final combina e adapta essas seções.

**Ordem das seções e obrigatoriedade:**

| Arquivo | Seção | Obrigatório |
|---------|-------|-------------|
| `01-apresentacao.md` | Apresentação e contexto do cliente | Sim |
| `02-escopo.md` | Escopo do projeto e entregáveis | Sim |
| `03-metodologia.md` | Abordagem e metodologia de trabalho | Recomendado |
| `04-investimento.md` | Valores, forma de pagamento e condições | Sim |
| `05-prazo.md` | Cronograma e marcos principais | Sim |
| `06-proximos-passos.md` | O que acontece após aprovação | Sim |
| `07-sobre-nos.md` | Apresentação da empresa/profissional | Opcional |

---

## Passo 1 — Carregar contexto

1. **Carregar o brief** — se houver handoff pendente de brief-extractor, usá-lo automaticamente.
   Se não: pedir ao usuário o path do brief ou contexto colado.

2. **Verificar escopo mínimo** — a proposta só pode ser gerada se o brief tiver:
   - `empresa` — identificada
   - `dores` ou `objetivos` — ao menos um definido
   - `escopo_esperado` — ao menos parcialmente declarado

   Se algum campo crítico estiver ausente:
   ```
   ⚠️ HALT — O brief não tem escopo suficiente para gerar proposta coerente.
   
   Faltando: {campo1}, {campo2}
   
   Opções:
   1. Complete o brief via @brief-extractor *review
   2. Forneça os campos ausentes diretamente aqui
   ```

3. **Ler os templates** de `squads/client-onboarding/templates/proposal/`.

---

## Passo 2 — Gerar proposta seção a seção

Gerar cada seção adaptando o template ao contexto do brief. Seguir a ordem canônica.

### Seção 01 — Apresentação

Abrir a proposta contextualizando o cliente:
- Reconhecer a situação atual e as dores identificadas
- Apresentar brevemente o que a proposta resolve
- Tom: empático, direto, orientado ao valor (não técnico)

```markdown
## Contexto

{Empresa} {descrição breve do setor e situação atual}.

{Dor principal ou desafio que motivou esta proposta}.

Esta proposta apresenta como podemos {resolver/transformar/implementar} {escopo em 1 frase}.
```

### Seção 02 — Escopo e Entregáveis

Listar o que está incluído no projeto:
- Entregas concretas (não atividades genéricas)
- O que está fora do escopo (se declarado no brief)
- Integrações incluídas

```markdown
## Escopo

### O que está incluído

{lista numerada de entregáveis concretos}

### Fora do escopo

{lista do que não está incluído | "A definir — [REVISAR]"}
```

### Seção 03 — Metodologia (se aplicável)

Descrever como o trabalho será executado:
- Fases do projeto (discovery, desenvolvimento, entrega, revisão)
- Modelo de comunicação (reuniões, ferramentas, canais)
- Processo de aprovação de entregas

Omitir esta seção se o projeto for muito simples ou transacional.

### Seção 04 — Investimento

```markdown
## Investimento

### Valor

**Total:** R$ {valor} [REVISAR — ajustar antes de enviar]

### Forma de Pagamento

{condições de pagamento — ex: 50% na assinatura, 50% na entrega | [REVISAR]}

### Validade da Proposta

Esta proposta é válida por {N} dias corridos a partir da data de emissão.
```

⚠️ Sempre marcar valor e condições com `[REVISAR]` — são campos de decisão humana.

### Seção 05 — Prazo

```markdown
## Cronograma

**Início previsto:** {data de início | a combinar após aprovação}
**Entrega estimada:** {prazo esperado do brief}

### Marcos Principais

| Fase | Prazo estimado |
|------|----------------|
| {fase 1} | {N} semanas |
| {fase 2} | {N} semanas |
| {entrega final} | {data estimada} |
```

### Seção 06 — Próximos Passos

```markdown
## Próximos Passos

Após a aprovação desta proposta:

1. Assinatura do contrato de prestação de serviços
2. Pagamento da primeira parcela
3. Kickoff: reunião de alinhamento e início do projeto
4. Compartilhamento de acessos e materiais necessários

**Prazo para resposta:** esta proposta é válida até {data}.
```

### Seção 07 — Sobre Nós (opcional)

Incluir apenas se o cliente não conhece bem o prestador. Omitir em propostas de renovação ou clientes com histórico.

---

## Passo 3 — Revisar e sinalizar

Após gerar todas as seções, percorrer a proposta e:

1. **Verificar consistência:**
   - Valor menciona o mesmo escopo descrito na seção 02
   - Prazo é compatível com o cronograma da seção 05
   - Entregáveis da proposta batem com o brief

2. **Marcar campos que dependem de decisão humana:**
   - Qualquer valor financeiro → `[REVISAR]`
   - Condições de pagamento não confirmadas → `[REVISAR]`
   - Datas absolutas não confirmadas → `[REVISAR]`
   - Cláusulas de exclusividade, SLA, garantia → `[REVISAR]`

3. **Exibir resumo de campos [REVISAR] ao usuário:**
   ```
   ⚠️ Campos que precisam de revisão antes de enviar:
   - Seção 04 — Investimento: valor total (R$ [REVISAR])
   - Seção 05 — Prazo: data de início (a combinar)
   ```

---

## Passo 4 — Salvar e gerar handoff

### Estrutura do documento final

```markdown
# Proposta Comercial — {Empresa}

**Data:** YYYY-MM-DD
**Válida até:** YYYY-MM-DD
**Elaborada por:** [REVISAR — nome/empresa do prestador]

---

{seção 01 — apresentação}
{seção 02 — escopo}
{seção 03 — metodologia — se aplicável}
{seção 04 — investimento}
{seção 05 — prazo}
{seção 06 — próximos passos}
{seção 07 — sobre nós — se aplicável}

---

*Proposta gerada por @proposal-writer — revisar [REVISAR] antes de enviar ao cliente*
```

### Salvar o arquivo

```
data/outputs/client-onboarding/proposals/proposal-writer_proposal-{empresa}-{INSTANCE}-YYYY-MM-DD.md
```

### Gerar handoff (se pipeline continua)

```yaml
handoff:
  from_agent: proposal-writer
  to_agent: contract-writer
  last_command: "*write"
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    output_file: "data/outputs/client-onboarding/proposals/proposal-writer_proposal-{empresa}-{INSTANCE}-YYYY-MM-DD.md"
    empresa: "{empresa}"
    brief_file: "{path do brief usado}"
    campos_revisar: {N}
  next_action: "*draft {empresa}"
```

Salvar em `.kairos-core/runtime/handoffs/handoff-proposal-writer-to-contract-writer-{timestamp}.yaml`.

### Confirmar ao usuário

```
✅ Proposta salva:
   data/outputs/client-onboarding/proposals/proposal-writer_proposal-{empresa}-{INSTANCE}-YYYY-MM-DD.md

⚠️ {N} campo(s) marcados com [REVISAR] — revisar antes de enviar ao cliente.

Próximo passo (após aprovação do cliente): @contract-writer *draft {empresa}
```
