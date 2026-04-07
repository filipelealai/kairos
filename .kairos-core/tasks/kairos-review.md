---
task: Kairos Review
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: validation
elicit: false
Entrada: |
  - story_id: ID da story a revisar (ex: "1.2", "2.1") — obrigatório
Saida: |
  - gate_file: docs/qa/gates/{story-id}-{YYYY-MM-DD}.yaml
  - verdict: PASS | BLOCK exibido em tela
Checklist:
  - "[ ] Localizar e ler docs/stories/{epic}.{N}.story.md"
  - "[ ] Extrair: lista de ACs, arquivos esperados, escopo"
  - "[ ] Verificar cada AC — evidência de implementação"
  - "[ ] Verificar que arquivos declarados em 'Arquivos Esperados' existem"
  - "[ ] Verificar consistência de referências cruzadas"
  - "[ ] Verificar version bump e CHANGELOG se MAJOR/MINOR"
  - "[ ] Calcular quality_score"
  - "[ ] Determinar verdict: PASS ou BLOCK"
  - "[ ] Salvar gate em docs/qa/gates/"
  - "[ ] Exibir resultado formatado"
---

# *review — Validação com Gate PASS/BLOCK

## Execução

### Passo 1 — Localizar a story

Construa o path: `docs/stories/{story_id}.story.md`
- Se `story_id = "1.2"` → `docs/stories/1.2.story.md`
- Se não encontrar → **BLOCK imediato**: "Story {story_id} não encontrada."

Leia o arquivo completo. Extraia:
- **Título**
- **Status** atual
- **Epic**
- **Critérios de aceite** (lista de ACs com checkboxes)
- **Arquivos Esperados** (seção "Dev Agent Record > Arquivos Esperados" ou "File List")
- **Escopo** declarado

### Passo 2 — Verificar ACs

Para cada AC da story, determine:

**Como verificar (por tipo de AC):**

| Tipo de AC | Como checar |
|------------|-------------|
| "Arquivo X existe" | Verificar se o arquivo existe no repo |
| "Comando Y executa sem erro" | Anotar como "requer execução manual — não verificável estaticamente" |
| "Campo Z está no JSON" | Ler o arquivo e verificar estrutura |
| "Versão bumped" | Comparar core-config.yaml com CHANGELOG.md |
| "CHANGELOG atualizado" | Verificar se CHANGELOG.md tem entrada para a versão |
| "Story/epic atualizado" | Ler o arquivo referenciado |
| "Persona do agente X tem campo Y" | Ler o arquivo do agente |

Marque cada AC como:
- ✅ `covered` — evidência encontrada
- ❌ `gap` — não encontrado ou verificação falhou
- ⚠️ `manual` — requer execução manual, não verificável estaticamente

### Passo 3 — Verificar arquivos declarados

Para cada arquivo em "Arquivos Esperados" / "File List":
- Verificar se existe
- Marcar como presente ✅ ou ausente ❌

### Passo 4 — Checks de governança

Verifique para MAJOR e MINOR (pular para PATCH):
- `version_bumped`: CHANGELOG.md tem entrada mais recente que a anterior? A versão em core-config.yaml foi atualizada?
- `changelog_updated`: a entrada do CHANGELOG descreve esta mudança?

Para qualquer tipo:
- `story_file_consistent`: os campos Status, Epic e Escopo na story fazem sentido com o conteúdo?
- `no_broken_references`: tasks, rules, agentes referenciados no corpo da story existem?

### Passo 5 — Calcular quality_score

```
score = 100

Para cada AC com gap: score -= 15
Para cada arquivo ausente: score -= 10
Para cada check de governança BLOCK: score -= 20
Para cada referência quebrada: score -= 5

score = max(0, score)
```

### Passo 6 — Determinar verdict

```
BLOCK se qualquer um:
  - AC crítico (com "[ ]" obrigatório) marcado como gap
  - Arquivo obrigatório ausente
  - Check de governança crítico falhou
  - quality_score < 60

PASS se:
  - Todos os ACs críticos cobertos (gaps apenas em ACs "manual" são aceitáveis)
  - Todos os arquivos declarados presentes
  - quality_score >= 60
```

### Passo 7 — Salvar gate

Crie `docs/qa/gates/{story_id}-{YYYY-MM-DD}.yaml`:

```yaml
schema: 1
story: "{story_id}"
story_title: "{título}"
epic: {N}
verdict: "PASS | BLOCK"
reviewer: "Kairos (@kairos)"
reviewed_at: "{ISO timestamp}"
quality_score: {N}

ac_coverage:
  covered:
    - "AC1: descrição"
  gaps:
    - "AC2: descrição — motivo do gap"
  manual:
    - "AC3: descrição — requer execução manual"

checks:
  version_bumped: "PASS | BLOCK | N/A"
  changelog_updated: "PASS | BLOCK | N/A"
  story_file_consistent: "PASS | BLOCK"
  files_exist: "PASS | BLOCK"
  no_broken_references: "PASS | BLOCK"

issues:
  - severity: "critical | high | medium | low"
    description: "..."
    recommendation: "..."

blocking_issues:
  - "Descrição do que está bloqueando (apenas issues críticos)"

recommendations:
  - "Sugestão não bloqueante"
```

### Passo 8 — Exibir resultado

**Se PASS:**
```
✅ GATE PASS — Story {story_id}
Quality Score: {N}/100

ACs verificados: {N}/{total}
Arquivos presentes: {N}/{total}

Gate salvo em: docs/qa/gates/{story_id}-{data}.yaml

Próximo passo: *version {tipo} "descrição" → *pre-push → *push
```

**Se BLOCK:**
```
🚫 GATE BLOCK — Story {story_id}
Quality Score: {N}/100

Issues Bloqueantes:
  ❌ {issue 1}
  ❌ {issue 2}

ACs com gap:
  ❌ {AC}

Resolva os issues acima e rode *review {story_id} novamente.
Gate salvo em: docs/qa/gates/{story_id}-{data}.yaml
```
