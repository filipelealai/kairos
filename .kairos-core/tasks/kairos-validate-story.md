---
task: Kairos Validate Story
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: validation
elicit: false
Entrada: |
  - story_id: ID da story a validar (ex: "2.1", "3.1") — obrigatório
Saida: |
  - relatório de validação exibido em tela com cada check marcado
  - verdict: VÁLIDA | RESSALVA | INVÁLIDA
Checklist:
  - "[ ] Localizar docs/stories/{epic}.{N}.story.md"
  - "[ ] Verificar campos de cabeçalho obrigatórios"
  - "[ ] Verificar seções obrigatórias presentes"
  - "[ ] Verificar qualidade dos ACs (específicos, testáveis, ≥3)"
  - "[ ] Verificar consistência do ID e nomenclatura"
  - "[ ] Verificar referências cruzadas (epic file, dependências)"
  - "[ ] Calcular score e determinar verdict"
  - "[ ] Exibir relatório formatado com cada check marcado"
---

# *validate-story — Validação de Formato e Qualidade da Story

Esta task valida o **documento da story em si** — se está bem formado, completo e com ACs de qualidade.
Não verifica implementação (isso é *review). É o passo anterior: garantir que a story é válida antes de entregar ao executor.

---

## Execução

### Passo 1 — Localizar a story

Construa o path: `docs/stories/{story_id}.story.md`
- Se não encontrar → **INVÁLIDA imediato**: "Story {story_id} não encontrada em docs/stories/."

Leia o arquivo completo.

---

### Passo 2 — Verificar campos de cabeçalho

Cada campo: ✅ OK / ⚠️ RESSALVA / ❌ FALHA

| Campo | Critério | Peso |
|-------|----------|------|
| `**Epic:**` | Presente e é um número (ex: `3`) | obrigatório |
| `**Status:**` | Um de: `Draft`, `In Progress`, `In Review`, `Done` | obrigatório |
| `**Complexidade:**` | Um de: `P`, `M`, `G` | obrigatório |
| `**Criada por:**` | Presente e não vazio | obrigatório |
| `**Data:**` | Formato `YYYY-MM-DD` | obrigatório |

Campos ausentes ou com valor inválido → ❌ FALHA.
Campo presente mas valor sem padrão claro (ex: data em formato livre) → ⚠️ RESSALVA.

---

### Passo 3 — Verificar seções obrigatórias

| Seção | Critério | Peso |
|-------|----------|------|
| `## Objetivo` | Presente, ≥ 1 parágrafo com conteúdo real | obrigatório |
| `## Critérios de Aceite` | Presente, ≥ 3 itens com checkboxes (`- [ ]`) | obrigatório |
| `## Fora de Escopo` | Presente (pode ser vazia com justificativa) | recomendado |
| `## Dependências` | Presente (pode listar "Nenhuma") | recomendado |
| `## Change Log` | Presente com pelo menos uma entrada | obrigatório |

Seção obrigatória ausente → ❌ FALHA.
Seção recomendada ausente → ⚠️ RESSALVA.
Seção presente mas vazia sem justificativa → ⚠️ RESSALVA.

---

### Passo 4 — Verificar qualidade dos ACs

Para cada AC, classifique:

**✅ AC bem escrito — é específico e testável:**
- "Arquivo `docs/qa/gates/` existe no repositório"
- "`kairos-new-story.md` cria `docs/stories/{epic}.{N}.story.md` com template completo"
- "CHANGELOG.md tem entrada com a versão bumped"

**⚠️ AC com ressalva — verificável mas vago:**
- "O agente responde corretamente" (o que é "corretamente"?)
- "A task funciona" (funciona como, em que condições?)
- "Documentação atualizada" (qual arquivo? que seção?)

**❌ AC inválido — não verificável ou muito vago:**
- "Tudo funciona bem"
- "O sistema está melhor"
- "Boa cobertura"
- AC que é apenas uma intenção, não um critério mensurável

Regras de pontuação:
- Mínimo 3 ACs → se < 3 ACs: ❌ FALHA
- Se > 50% dos ACs são ❌ inválidos → ❌ FALHA
- Se há ACs ⚠️ mas nenhum ❌ → ⚠️ RESSALVA
- Todos ✅ → OK nesta dimensão

---

### Passo 5 — Verificar consistência de ID e nomenclatura

- Nome do arquivo segue `{epic}.{N}.story.md`? (ex: `3.1.story.md` para epic 3, story 1)
- O número do epic no nome bate com o campo `**Epic:**` no cabeçalho?
- O story_id solicitado bate com o epic declarado no arquivo?
- Story está listada em `docs/stories/README.md`?
- Story está listada no epic file `docs/epics/epic-{N}-*.md`?

Inconsistência de ID → ❌ FALHA.
Não listada em README mas arquivo existe → ⚠️ RESSALVA.

---

### Passo 6 — Verificar referências cruzadas

- Epic file referenciado existe? (`docs/epics/epic-{N}-*.md`)
- Arquivos listados em `## Dependências` existem?
- Tasks ou agentes mencionados no corpo existem em `.kairos-core/tasks/` ou `.claude/commands/kairos/agents/`?

Referência quebrada a arquivo obrigatório → ❌ FALHA.
Menção informal que não pode ser verificada estaticamente → ignorar.

---

### Passo 7 — Calcular score e determinar verdict

**Score começa em 100:**

```
Para cada campo obrigatório de cabeçalho ausente/inválido: -15
Para cada seção obrigatória ausente: -20
Para cada seção recomendada ausente: -5
Para cada AC ❌ inválido: -10
Se total de ACs < 3: -25
Para cada inconsistência de ID: -15
Para cada referência cruzada quebrada (obrigatória): -10

score = max(0, score)
```

**Verdict:**

```
INVÁLIDA se qualquer:
  - Campo obrigatório de cabeçalho ausente ou inválido
  - Seção obrigatória ausente
  - < 3 ACs
  - > 50% ACs são ❌ inválidos
  - Inconsistência de ID entre nome do arquivo e campo Epic
  - score < 50

RESSALVA se:
  - Nenhuma condição de INVÁLIDA
  - Alguma ⚠️ (seção recomendada ausente, ACs vagos, não listada em README, referência informal)
  - score entre 50-79

VÁLIDA se:
  - Todos os critérios obrigatórios OK
  - Nenhum ou poucos ⚠️ (apenas sugestões)
  - score >= 80
```

---

### Passo 8 — Exibir relatório

```
📋 VALIDAÇÃO DA STORY — {story_id}: {título}

━━━ CABEÇALHO ━━━
  {✅/⚠️/❌} Epic: {valor}
  {✅/⚠️/❌} Status: {valor}
  {✅/⚠️/❌} Complexidade: {valor}
  {✅/⚠️/❌} Criada por: {valor}
  {✅/⚠️/❌} Data: {valor}

━━━ SEÇÕES ━━━
  {✅/⚠️/❌} Objetivo: {nota}
  {✅/⚠️/❌} Critérios de Aceite: {N} ACs — {nota}
  {✅/⚠️/❌} Fora de Escopo: {nota}
  {✅/⚠️/❌} Dependências: {nota}
  {✅/⚠️/❌} Change Log: {nota}

━━━ QUALIDADE DOS ACs ━━━
  {✅/⚠️/❌} "{AC 1}" — {nota}
  {✅/⚠️/❌} "{AC 2}" — {nota}
  ...

━━━ CONSISTÊNCIA ━━━
  {✅/⚠️/❌} ID e nomenclatura: {nota}
  {✅/⚠️/❌} Listada em README: {nota}
  {✅/⚠️/❌} Listada no epic file: {nota}
  {✅/⚠️/❌} Referências cruzadas: {nota}

━━━ RESULTADO ━━━
Score: {N}/100
```

**Se VÁLIDA:**
```
✅ STORY VÁLIDA — {story_id}

A story está bem formada e pronta para execução.
Próximo passo: Claude Code implementa → move status para "In Review" → *review {story_id}
```

**Se RESSALVA:**
```
⚠️ STORY COM RESSALVAS — {story_id}

A story pode ser executada, mas tem pontos a melhorar:
  ⚠️ {ressalva 1}
  ⚠️ {ressalva 2}

Recomendação: corrigir as ressalvas antes de entregar ao executor, ou aceitar e seguir em frente.
```

**Se INVÁLIDA:**
```
❌ STORY INVÁLIDA — {story_id}

A story precisa ser corrigida antes de ser executada:
  ❌ {falha 1}
  ❌ {falha 2}

Corrija os itens acima e rode *validate-story {story_id} novamente.
```
