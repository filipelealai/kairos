---
kairos-owned: true
kairos-version: 2.0.0
---

# Integrações Externas — Skills, CLIs, MCPs e APIs

## Hierarquia de Integração

A escolha entre CLI, MCP e script depende do **tipo de operação**, não de uma ordem fixa:

```
Skills do Claude Code       → quando existe skill para o caso
        ↓
CLI do serviço              → comandos operacionais (deploy, migrate, generate, create)
MCP configurado             → queries e inspeção estruturada (list, get, describe, search)
        ↓
Scripts TypeScript          → lógica customizada sem CLI/MCP disponível
        ↓
HTTP direto                 → último recurso
```

### Quando preferir CLI

CLIs são preferíveis para **ações que mudam estado**:
- Deploy, migrate, push, apply, generate, create, delete
- Operações onde o CLI é a interface canônica do serviço (ex: `supabase db push`, `gh pr create`)
- Quando a saída importa menos que a execução (confirmar que rodou, não parsear resposta)
- CLIs bem mantidos têm flag `--json` ou `--format json` para output estruturado quando necessário

**Vantagem sobre MCP:** sem overhead de schema no contexto, saída direta, geralmente mais completo em cobertura de features.

### Quando preferir MCP

MCPs são preferíveis para **consultas que retornam dados estruturados**:
- Listar recursos, inspecionar schema, buscar registros, obter logs
- Quando a resposta precisa ser processada (filtrar, extrair campos, comparar)
- Operações multi-passo com validação intermediária

**Vantagem sobre CLI:** resposta já estruturada para consumo do Claude, sem parsing de texto, erros formatados.

### Exemplos práticos

Os exemplos abaixo usam Supabase e GitHub — ferramentas comuns, não específicas do Kairos. A lógica se aplica a qualquer serviço com CLI + MCP disponíveis.

| Tarefa | Preferir | Exemplo |
|--------|----------|---------|
| Operação que muda estado | CLI | `supabase db push`, `gh pr create` |
| Geração de artefatos | CLI | `supabase gen types`, `supabase migration new` |
| Consulta / inspeção estruturada | MCP | `execute_sql`, `list_tables` |
| Deploy | CLI | `supabase functions deploy`, `gh workflow run` |
| Logs / métricas | MCP ou CLI com `--json` | `supabase functions logs` |

---

## Skills Disponíveis

Skills ativas são listadas nos `system-reminder` do Claude Code — dependem da configuração do usuário/equipe.

Antes de criar um script para uma tarefa, verificar se já existe uma skill que cobre o caso.

**Skills nativas do Claude Code** (sempre disponíveis):

| Skill | Quando usar |
|-------|-------------|
| `/schedule` | Agendar execuções periódicas de agentes (workers) |
| `update-config` | Modificar `settings.json` — hooks, permissões, env vars |

**Skills de projeto** variam conforme o que está configurado. Exemplos comuns:

| Tipo de skill | Exemplos |
|---------------|---------|
| Automação/workflow | skills `n8n-*` se n8n-mcp estiver configurado |
| AI/API | skill `claude-api` para código com Anthropic SDK |
| UI/frontend | skills de componentes, design, etc. |

---

## MCPs Configurados

MCPs disponíveis dependem do projeto. No Kairos, verificar `.claude/settings.json` e `settings.local.json` para MCPs ativos.

**Diretrizes de uso:**

1. **Ler a documentação antes de usar** — MCPs geralmente expõem uma tool de documentação (ex: `tools_documentation`, `get_node`). Não assumir parâmetros de operações desconhecidas.
2. **Operações de leitura primeiro** — listar antes de criar, verificar antes de modificar.
3. **Validar antes de executar** — MCPs de workflow geralmente têm tools de validação — usá-las.
4. **Registrar integrações no manifesto do squad** — se um squad depende de um MCP, declarar em `squads/{squad}/squad.yaml`.

---

## Scripts TypeScript

Quando não há skill ou MCP disponível:

- Scripts em `src/agents/` para computação e integração com APIs externas
- Usar `src/tools/claude.ts` para qualquer chamada à Claude API — nunca instanciar `Anthropic` diretamente nos agentes
- Credenciais e URLs em `.env` — nunca hardcoded, usar `.env.example` como template
- Preferir ESM (`import/export`), sem CommonJS

---

## Ações com Side Effects

Ações que modificam estado externo (envio, escrita, deleção, disparo) devem ser:

1. **Explícitas** — o agente informa o que vai fazer antes de fazer
2. **Confirméveis** — quando irreversível, pedir confirmação ao usuário antes de executar
3. **Scoped ao squad** — cada squad define quais sistemas seus agentes têm autoridade para modificar (ver `agent-authority.md`)

> Restrições específicas de squad (ex: "não enviar X diretamente", "sistema Y tem controle exclusivo") vivem em `squads/{squad}/rules/` — não nesta rule.

---

## Configuração de Novas Integrações

Ao adicionar uma nova integração a um squad:

1. Declarar em `squads/{squad}/squad.yaml` (campo `integrations`)
2. Adicionar variáveis necessárias em `.env.example`
3. Documentar campos/gotchas em `.kairos-core/agents/{agent-id}/MEMORY.md`
4. Se for gotcha sistêmico: promover para `.kairos-core/data/kairos-kb.md`
