# Kairos Knowledge Base

> Base de conhecimento curada do framework. Contém decisões arquiteturais, gotchas do sistema, padrões validados e referências rápidas.
> Carregada sob demanda via `@kairos *kb` ou `@kairos *kb {tópico}`.

---

## Índice

- [Decisões Arquiteturais](#decisoes-arquiteturais)
- [Webhook de Leads](#webhook-de-leads)
- [Convenções de Naming](#convencoes-de-naming)
- [Erros Comuns](#erros-comuns)
- [Padrões Validados](#padroes-validados)
- [Referências Rápidas](#referencias-rapidas)

---

## Decisões Arquiteturais

### Por que YAML-in-Markdown para personas?

**Decisão:** Agentes definidos em `.claude/commands/kairos/agents/*.md` usam YAML embutido em Markdown, não JSON nem YAML puro.

**Motivo:** Claude Code carrega arquivos `.md` de commands automaticamente ao mencionar `@nome`. O Markdown permite seções legíveis por humanos (guias, exemplos) ao lado do YAML estruturado que o Claude interpreta. JSON puro seria menos legível; YAML puro não suportaria as seções de guia.

**Trade-off aceito:** Parsing implícito pelo Claude (não programático) — funciona bem porque o Claude entende a estrutura, mas não há validação automática de schema.

---

### Por que `.kairos-core/` em vez de `.kairos/`?

**Decisão:** Tudo de framework vai em `.kairos-core/` — não existe mais `.kairos/` separado.

**Motivo:** `.kairos/` existia só com `.gitignore` — era um placeholder sem propósito claro. Consolidar em `.kairos-core/runtime/` para handoffs e `.kairos-core/data/` para configs elimina um diretório sem semântica definida.

---

### Por que `data/outputs/{squad}/{tipo}/` com prefixo de agente?

**Decisão:** Outputs seguem o padrão `data/outputs/{squad}/{tipo}/{agent-id}_{filename}-YYYY-MM-DD.{ext}`.

**Motivo:** Permite que `data/` sirva para outros fins além de outputs (datasets, fixtures), separa por squad para quando houver múltiplos squads, e o prefixo de agente torna óbvio qual agente gerou cada arquivo ao listar o diretório.

**Exemplo:** `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-2026-04-14.csv`

---

### Por que scripts TypeScript sem AI para campaign-analyst e lead-scorer?

**Decisão:** `campaign-analyst.ts` e `lead-scorer.ts` são computação pura sem chamadas à Claude API.

**Motivo:** Métricas e scores são determinísticos — não precisam de linguagem natural. Usar AI aqui seria mais lento, mais caro e menos auditável. Apenas `niche-classifier.ts` e `email-writer.ts` precisam de AI (classificação semântica e geração de texto).

---

### Por que `pre_push_passed` é estado de sessão e não arquivo?

**Decisão:** O guard de `*push` é um estado em memória da sessão, não um arquivo em disco.

**Motivo:** Se fosse um arquivo, uma sessão poderia fazer `*pre-push`, encerrar, abrir nova sessão e fazer `*push` sem re-verificar. O estado de sessão força re-execução do `*pre-push` a cada nova sessão — mais seguro.

**Trade-off aceito:** Não persiste entre sessões (comportamento intencional).

---

## Webhook de Leads

### Campos e Gotchas

**URL:** `https://n8n.vendoteca.com/webhook/kairos-leads`
**Método:** GET | **Autenticação:** nenhuma | **Resposta:** `{ leads: Lead[] }`

| Campo | Gotcha | Solução |
|-------|--------|---------|
| `Capital Social` | Pode retornar como number ou string | `parseFloat(String(v))` |
| `Nome Fantasia` | Frequentemente vazio | Fallback para `Nome` |
| `Cidade` | Vem em UPPERCASE | `.toLowerCase()` + capitalize |
| `Status do Envio` | Pode ser `""`, `"NÃO ENVIADO"` ou `"ENVIADO"` | Verificar explicitamente |
| Qualquer campo string | Pode ser null ou number vindo do Sheets | `String(value || "")` |

### Filtro de Elegibilidade

Lead elegível para disparo:
```
Pode disparar === "SIM"
AND (Status do Envio === "" OR Status do Envio === "NÃO ENVIADO")
AND Situação === "ATIVA"
```

---

## Convenções de Naming

| Item | Convenção | Exemplo |
|------|-----------|---------|
| ID de agente | `kebab-case` | `email-writer` |
| Persona (nome) | `PascalCase` | `Eva` |
| Task file | `kebab-case.md` | `write-emails.md` |
| Output file | `{agent-id}_{tipo}-YYYY-MM-DD.{ext}` | `lead-scorer_scored-leads-2026-04-14.csv` |
| Story file | `{epic}.{N}.story.md` | `4.1.story.md` |
| Epic file | `epic-{N}-{slug}.md` | `epic-4-novos-escopos.md` |
| Handoff file | `handoff-{from}-to-{to}-{ts}.yaml` | `handoff-lead-scorer-to-niche-classifier-20260414.yaml` |
| Gate file | `{story-id}-YYYY-MM-DD.yaml` | `3.1-2026-04-06.yaml` |

---

## Erros Comuns

### "Cannot read property of undefined" no script TS

**Causa:** Campo do webhook retornado como null/undefined.
**Solução:** Sempre fazer `String(lead.campo || "")` para strings, `parseFloat(String(lead.campo || 0))` para números.

---

### Agente não detecta handoff na ativação

**Causa:** Handoff marcado como `consumed: true` ou diretório de handoffs vazio.
**Verificação:** `ls .kairos-core/runtime/handoffs/` — arquivo existe e tem `consumed: false`?

---

### `*push` recusado com "pré-push não executado"

**Causa:** Sessão reiniciada após `*pre-push` — o estado de sessão foi perdido.
**Solução:** Rodar `*pre-push` novamente na sessão atual antes de `*push`.

---

### Score 0 em muitos leads

**Causa:** Atividade Principal não match com nenhum nicho do algoritmo.
**Solução:** Rodar `@niche-classifier *classify` para atualizar o mapa de nichos, depois re-score.

---

## Padrões Validados

### Abertura de e-mail por nicho

| Nicho | Abertura que funciona |
|-------|----------------------|
| Barbearia | Perspectiva do cliente que não volta |
| Salão | Volume de perguntas no WhatsApp |
| Clínica estética médica | Tempo perdido em triagem |
| Odontologia | Paciente que marca e não comparece |

*Preencher com padrões validados após feedback de campanha real.*

---

### Tiers de leads e tom de e-mail

| Tier | Score | Capital Social | Tom recomendado |
|------|-------|----------------|-----------------|
| A | ≥55 | Variado | Direto, foco em resultado |
| B | 35–54 | R$10k–100k | Empático, foco em crescimento |
| C | 15–34 | R$1k–10k | Simples, foco em economia de tempo |
| D | <15 | MEI baixo | Muito breve, foco em praticidade |

---

## Referências Rápidas

### Pipeline completo

```
@campaign-analyst *analyze → @lead-scorer *score
→ @niche-classifier *classify → @email-writer *write 20
→ n8n dispara → @campaign-analyst *analyze (novo ciclo)
```

### Ciclo de desenvolvimento do Kairos

```
@kairos *new-epic → @kairos *new-story → @kairos *validate-story
→ Claude Code implementa → @kairos *review
→ @kairos *version → @kairos *pre-push → @kairos *push
```

### Versioning rules

| Tipo | Quando | Story obrigatória? |
|------|--------|-------------------|
| PATCH | Bug fix, ajuste de instrução, atualização de MEMORY | Não |
| MINOR | Novo agente, task, rule ou squad | Sim |
| MAJOR | Novo squad/escopo, breaking change | Sim |

---

*Última atualização: 2026-04-14*
