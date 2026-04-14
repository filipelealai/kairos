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

| Tarefa | Preferir |
|--------|----------|
| `supabase migration new` / `db push` | CLI |
| `supabase gen types` | CLI |
| Consultar tabela / executar SQL | MCP (`execute_sql`) |
| Inspecionar RLS policies | MCP |
| `gh pr create` / `gh issue close` | CLI |
| Listar PRs abertos com metadados | CLI (`gh pr list --json`) ou MCP |
| Deploy de edge function | CLI (`supabase functions deploy`) |
| Ver logs de edge function | MCP ou CLI (`supabase functions logs`) |

---

## Skills Disponíveis

Skills ativas são listadas nos `system-reminder` do Claude Code. Exemplos relevantes para o Kairos:

| Skill | Quando usar |
|-------|-------------|
| `/schedule` | Agendar execuções periódicas de agentes (workers) |
| `update-config` | Modificar `settings.json` — hooks, permissões, env vars |
| `n8n-*` | Qualquer operação no n8n (workflows, nodes, validação) |
| `claude-api` | Código que usa `@anthropic-ai/sdk` diretamente |

Antes de criar um script para uma tarefa, verificar se já existe uma skill que cobre o caso.

---

## MCPs Configurados

MCPs disponíveis dependem do projeto. No Kairos, verificar `.claude/settings.json` e `settings.local.json` para MCPs ativos.

**Diretrizes de uso:**

1. **Ler a documentação antes de usar** — `mcp__n8n-mcp__tools_documentation`, `get_node`, etc. Não assumir parâmetros de operações desconhecidas.
2. **Operações de leitura primeiro** — listar antes de criar, verificar antes de modificar.
3. **Validar antes de executar** — MCPs de workflow (n8n, etc.) geralmente têm tools de validação — usá-las.
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

> Restrições específicas de squad (ex: "não enviar e-mail diretamente no cold-prospecting") vivem em `agent-authority.md` e `campaign-lifecycle.md` — não nesta rule.

---

## Configuração de Novas Integrações

Ao adicionar uma nova integração a um squad:

1. Declarar em `squads/{squad}/squad.yaml` (campo `integrations`)
2. Adicionar variáveis necessárias em `.env.example`
3. Documentar campos/gotchas em `.kairos-core/agents/{agent-id}/MEMORY.md`
4. Se for gotcha sistêmico: promover para `.kairos-core/data/kairos-kb.md`
