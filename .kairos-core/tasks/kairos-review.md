---
kairos-owned: true
kairos-version: 2.0.0
task: Kairos Review
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: validation
elicit: false
Entrada: |
  - story_id: ID da story a revisar (ex: "1.2", "2.1") — opcional
    Se omitido: detectar automaticamente stories com Status "In Review"
Saida: |
  - gate_file: docs/qa/gates/{story-id}-{YYYY-MM-DD}.yaml
  - verdict: PASS | RESSALVA | BLOCK exibido em tela
Checklist:
  - "[ ] Resolver story_id: argumento explícito ou auto-detect 'In Review'"
  - "[ ] Localizar e ler docs/stories/{epic}.{N}.story.md"
  - "[ ] Verificar cada AC — evidência de implementação"
  - "[ ] Verificar Execution Log do executor (anotações, decisões, pendências)"
  - "[ ] Verificar que arquivos declarados existem"
  - "[ ] Verificar consistência de referências cruzadas"
  - "[ ] Verificar version bump e CHANGELOG se MAJOR/MINOR"
  - "[ ] Calcular quality_score"
  - "[ ] Determinar verdict: PASS | RESSALVA | BLOCK"
  - "[ ] Salvar gate em docs/qa/gates/"
  - "[ ] Exibir resultado formatado com cada check marcado"
---

# *review — Validação de Implementação com Gate PASS/RESSALVA/BLOCK

Esta task valida se a **implementação** bate com o que a story especifica.
Para validar o formato do documento da story, use *validate-story.

---

## Pré-passo — Resolver story_id

**Se story_id foi fornecido:** usar diretamente.

**Se não foi fornecido:**
1. Listar todos os arquivos em `docs/stories/` com extensão `.story.md`
2. Para cada um, ler o campo `**Status:**`
3. Coletar os que têm `Status: In Review`
4. Se exatamente 1 → usar automaticamente, exibindo: `→ Revisando story em In Review: {id} — {título}`
5. Se múltiplas → listar e pedir que o usuário escolha: `Múltiplas stories In Review — qual revisar? {lista}`
6. Se nenhuma → exibir: `Nenhuma story com status "In Review" encontrada. Especifique um ID: *review {id}`

---

## Execução

### Passo 1 — Localizar a story

Construa o path: `docs/stories/{story_id}.story.md`
- Se não encontrar → **BLOCK imediato**: "Story {story_id} não encontrada."

Leia o arquivo completo. Extraia:
- **Título**, **Status**, **Epic**, **Complexidade**
- **Critérios de aceite** (lista de ACs com checkboxes)
- **Arquivos Esperados** / **File List** (se presente)
- **Execution Log** (se presente — seção adicionada pelo executor)
- **Escopo** declarado

---

### Passo 2 — Verificar ACs

Para cada AC da story, determine:

**Como verificar (por tipo de AC):**

| Tipo de AC | Como checar |
|------------|-------------|
| "Arquivo X existe" | Verificar se o arquivo existe no repo |
| "Arquivo X contém campo Y" | Ler o arquivo e verificar estrutura |
| "Versão bumped" | Comparar core-config.yaml com CHANGELOG.md |
| "CHANGELOG atualizado" | Verificar se tem entrada para a versão |
| "Story/epic atualizado" | Ler o arquivo referenciado |
| "Persona do agente X tem campo Y" | Ler o arquivo do agente |
| "Comando Y executa sem erro" | Marcar como ⚠️ manual |

Marque cada AC como:
- ✅ `covered` — evidência encontrada
- ⚠️ `manual` — requer execução manual, não verificável estaticamente
- ❌ `gap` — não encontrado ou verificação falhou

---

### Passo 3 — Ler Execution Log do executor

Se a story tem seção `## Execution Log`:
- Leia as anotações, decisões tomadas e pendências declaradas pelo executor
- Se há "Pendências / questões abertas" → são candidatas a ⚠️ ou issues no gate
- Se há "Notas para @kairos" → incorporar na análise do gate

Se a story **não tem** Execution Log mas o Status é "In Review":
- Adicionar ao gate: `⚠️ Execution Log ausente — executor não documentou o que foi feito`
- Não bloqueia, mas é issue de severidade `medium`

---

### Passo 4 — Verificar arquivos declarados

Para cada arquivo em "Arquivos Esperados" / "File List":
- Verificar se existe
- Marcar como ✅ presente ou ❌ ausente

---

### Passo 5 — Checks de governança

| Check | Quando | Como |
|-------|--------|------|
| `version_bumped` | MAJOR ou MINOR | CHANGELOG.md tem versão mais recente? core-config.yaml atualizado? |
| `changelog_updated` | MAJOR ou MINOR | Entrada do CHANGELOG descreve esta mudança? |
| `story_file_consistent` | Sempre | Status, Epic e Escopo na story fazem sentido com o conteúdo? |
| `files_exist` | Sempre | Arquivos declarados presentes? |
| `no_broken_references` | Sempre | Tasks, rules, agentes referenciados na story existem? |
| `execution_log_present` | Status = In Review | Executor adicionou Execution Log? |

Para PATCH (sem story obrigatória): `version_bumped` e `changelog_updated` → `N/A`.

---

### Passo 6 — Calcular quality_score

```
score = 100

Para cada AC com gap (❌): score -= 15
Para cada AC manual (⚠️) sem Execution Log confirmando: score -= 5
Para cada arquivo ausente (❌): score -= 10
Para cada check de governança BLOCK: score -= 20
Para cada referência quebrada: score -= 5
Execution Log ausente (story In Review): score -= 10
Issue de severidade critical (declarado em pendências do executor): score -= 15

score = max(0, score)
```

---

### Passo 7 — Determinar verdict

```
BLOCK se qualquer:
  - AC crítico marcado como gap (❌) e sem justificativa no Execution Log
  - Arquivo obrigatório ausente (❌)
  - Check de governança crítico falhou (version/changelog para MAJOR/MINOR)
  - quality_score < 50

RESSALVA se:
  - Nenhuma condição de BLOCK
  - Algum AC manual (⚠️) sem confirmação clara no Execution Log
  - Execution Log ausente
  - Issues de severidade medium/low
  - quality_score entre 50-79

PASS se:
  - Todos os ACs críticos cobertos (✅)
  - ACs manuais aceitáveis (⚠️ documentados ou com baixo risco)
  - Todos os arquivos obrigatórios presentes
  - Checks de governança OK
  - quality_score >= 80
```

---

### Passo 8 — Salvar gate

Crie `docs/qa/gates/{story_id}-{YYYY-MM-DD}.yaml`:

```yaml
schema: 2
story: "{story_id}"
story_title: "{título}"
epic: {N}
verdict: "PASS | RESSALVA | BLOCK"
reviewer: "Kairos (@kairos)"
reviewed_at: "{ISO timestamp}"
quality_score: {N}
execution_log_found: true | false

ac_coverage:
  covered:
    - "✅ AC1: descrição"
  manual:
    - "⚠️ AC2: descrição — requer verificação manual"
  gaps:
    - "❌ AC3: descrição — motivo do gap"

files:
  present:
    - "✅ path/to/file"
  missing:
    - "❌ path/to/expected/file"

checks:
  version_bumped: "✅ PASS | ⚠️ RESSALVA | ❌ BLOCK | N/A"
  changelog_updated: "✅ PASS | ⚠️ RESSALVA | ❌ BLOCK | N/A"
  story_file_consistent: "✅ PASS | ⚠️ RESSALVA | ❌ BLOCK"
  files_exist: "✅ PASS | ❌ BLOCK"
  no_broken_references: "✅ PASS | ⚠️ RESSALVA | ❌ BLOCK"
  execution_log_present: "✅ PASS | ⚠️ RESSALVA"

issues:
  - severity: "critical | high | medium | low"
    description: "..."
    recommendation: "..."

blocking_issues:
  - "Descrição do que está bloqueando (apenas issues ❌ críticos)"

recommendations:
  - "⚠️ Sugestão não bloqueante"
```

---

### Passo 9 — Exibir resultado

**Cabeçalho sempre exibido:**
```
{✅/⚠️/🚫} GATE {PASS/RESSALVA/BLOCK} — Story {story_id}: {título}
Quality Score: {N}/100
Reviewed: {data}

━━━ CRITÉRIOS DE ACEITE ━━━
  ✅ "{AC 1}"
  ⚠️ "{AC 2}" — requer verificação manual
  ❌ "{AC 3}" — gap: {motivo}

━━━ ARQUIVOS ━━━
  ✅ {arquivo 1}
  ❌ {arquivo 2} — não encontrado

━━━ CHECKS DE GOVERNANÇA ━━━
  ✅ version_bumped
  ✅ changelog_updated
  ✅ story_file_consistent
  {✅/⚠️} execution_log_present: {nota}
  ✅ no_broken_references
```

**Se PASS:**
```
━━━ RESULTADO ━━━
✅ GATE PASS — implementação validada.

Gate salvo em: docs/qa/gates/{story_id}-{data}.yaml
Próximo passo: *version {tipo} "descrição" → *pre-push → *push
```

**Se RESSALVA:**
```
━━━ RESULTADO ━━━
⚠️ GATE RESSALVA — implementação aceita com observações.

Ressalvas (não bloqueantes):
  ⚠️ {ressalva 1}
  ⚠️ {ressalva 2}

Gate conta como PASS para fins de *pre-push, mas as ressalvas devem ser endereçadas.
Gate salvo em: docs/qa/gates/{story_id}-{data}.yaml
Próximo passo: *version {tipo} "descrição" → *pre-push → *push
```

**Se BLOCK:**
```
━━━ RESULTADO ━━━
🚫 GATE BLOCK — implementação não validada.

Issues bloqueantes:
  ❌ {issue 1}
  ❌ {issue 2}

ACs com gap:
  ❌ {AC}

Resolva os issues e rode *review {story_id} novamente.
Gate salvo em: docs/qa/gates/{story_id}-{data}.yaml
```
