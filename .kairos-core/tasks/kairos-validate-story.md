---
kairos-owned: true
kairos-version: 3.2.1
task: Kairos Validate Story
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: validation
elicit: false
Entrada: |
  - story_id: ID da story a validar (ex: "2.1", "3.1") OU "all" para validar todas as stories abertas
Saida: |
  - relatório de validação exibido em tela com cada check marcado
  - verdict: VÁLIDA | RESSALVA | INVÁLIDA (por story)
  - relatório consolidado quando argumento é "all"
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

## Modo de execução

O argumento determina o fluxo:

- **`*validate-story {id}`** → valida uma única story (fluxo padrão, Passos 1–8)
- **`*validate-story all`** → valida em massa todas as stories abertas (Passos A1–A6 abaixo, depois cada story passa pelos Passos 1–8)

---

## Execução em Massa — *validate-story all

### Passo A1 — Coletar stories abertas

1. Listar todos os arquivos em `docs/stories/` com padrão `*.story.md`
2. Para cada arquivo, ler o campo `**Status:**` do cabeçalho
3. Filtrar apenas as stories com status `Draft`, `In Progress` ou `In Review`
4. Ordenar por nome de arquivo (ordem numérica: 1.1, 2.1, 3.1, 3.2, etc.)

Se **nenhuma story aberta** for encontrada:
```
ℹ️ Nenhuma story aberta encontrada em docs/stories/.
Todas as stories estão com status Done ou o diretório está vazio.
```
→ encerrar.

---

### Passo A2 — Validar cada story sequencialmente

Para cada story da lista coletada no Passo A1:
- Executar os **Passos 1–8** do fluxo padrão (validação individual)
- Registrar o resultado (VÁLIDA / RESSALVA / INVÁLIDA) e a lista de problemas encontrados
- **Não interromper** ao encontrar INVÁLIDA — continuar para a próxima story
- Exibir separador visual entre stories para facilitar leitura:

```
────────────────────────────────────────────────────────────
```

---

### Passo A3 — Compilar resultados

Ao final de todas as validações, compilar:

```
resultados = [
  { story_id, titulo, verdict, problemas: [...] },
  ...
]

total_validadas = len(resultados)
total_validas   = resultados com verdict == "VÁLIDA"
total_ressalvas = resultados com verdict == "RESSALVA"
total_invalidas = resultados com verdict == "INVÁLIDA"
```

---

### Passo A4 — Exibir sumário executivo

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMÁRIO — *validate-story all

Stories validadas : {total_validadas}
✅ VÁLIDA          : {total_validas}
⚠️  RESSALVA        : {total_ressalvas}
❌ INVÁLIDA        : {total_invalidas}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Passo A5 — Exibir tabela consolidada

```
| Story | Título | Resultado | Problemas |
|-------|--------|-----------|-----------|
| {id}  | {título curto} | ✅ VÁLIDA / ⚠️ RESSALVA / ❌ INVÁLIDA | {lista compacta ou "—"} |
```

Para cada story RESSALVA ou INVÁLIDA, listar os problemas na coluna "Problemas" em formato compacto:
- Usar `;` como separador se houver múltiplos problemas
- Máximo 80 caracteres por célula — truncar com `...` se necessário

---

### Passo A6 — Recomendação final

**Se há stories INVÁLIDA:**
```
❌ {total_invalidas} stor(y/ies) precisam correção antes de *implement all.
   Corrija cada INVÁLIDA e rode *validate-story {id} individualmente para confirmar.
```

**Se há apenas RESSALVA (sem INVÁLIDA):**
```
⚠️  {total_ressalvas} stor(y/ies) têm ressalvas. Podem ser executadas — revise antes de *implement all.
```

**Se todas são VÁLIDA:**
```
✅ Todas as stories estão válidas. Backlog pronto para *implement all.
```

---

## Execução Individual — *validate-story {id}

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

**Verificação de ordem do cabeçalho:**
Se o bloco `⚠️ ATENÇÃO` estiver presente no arquivo, verificar se `**Criada por:**` e `**Data:**` aparecem **antes** dele. Se qualquer um desses campos aparecer após o bloco `⚠️ ATENÇÃO` → ❌ FALHA com mensagem: "Campos do cabeçalho deslocados para após o bloco ⚠️ ATENÇÃO".

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

**Verificação de estrutura dos ACs:**
Verificar se `## Critérios de Aceite` contém subseções `###`. Se contiver → ❌ FALHA com mensagem: "ACs organizados em subseções — formato deve ser lista plana de checkboxes".

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
Cabeçalho fora de ordem (Criada por/Data após bloco ⚠️ ATENÇÃO): -15
Para cada seção obrigatória ausente: -20
Subseções ### em Critérios de Aceite: -20
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
  - Campos do cabeçalho (Criada por/Data) deslocados para após o bloco ⚠️ ATENÇÃO
  - Seção obrigatória ausente
  - Critérios de Aceite contém subseções ###
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
  {✅/❌} Ordem dos campos: {nota — "campos antes do bloco ⚠️ ATENÇÃO" ou "Criada por/Data deslocados para após o bloco ⚠️ ATENÇÃO"}

━━━ SEÇÕES ━━━
  {✅/⚠️/❌} Objetivo: {nota}
  {✅/⚠️/❌} Critérios de Aceite: {N} ACs — {nota}
  {✅/❌} Estrutura dos ACs: {nota — "lista plana de checkboxes" ou "contém subseções ### — formato inválido"}
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
