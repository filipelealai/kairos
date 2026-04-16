---
kairos-owned: true
kairos-version: 3.1.0
---

# Kairos — Escopo e Arquitetura do Framework

**Versão:** 1.0
**Atualizado em:** 2026-04-16

---

## Visão Geral

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. O nome vem do grego καιρός — o tempo certo, o momento oportuno. Cada agente age quando faz sentido, não em qualquer momento.

O framework organiza trabalho em **squads**: grupos de agentes especializados que operam um domínio. Cada squad define seu próprio pipeline, integrações externas e agentes — o Kairos fornece a infraestrutura comum: governança, memória persistente, handoffs, workers agendados e ferramentas para criar e evoluir squads ao longo do tempo.

**Kairos não é uma aplicação** — é um framework de orquestração. Cada instância define seus próprios squads e objetivos.

---

## Propósito

O Kairos existe para resolver o problema de contexto e coordenação em sistemas multi-agente:

- **Coordenação:** agentes especializados colaboram em pipelines via handoffs estruturados
- **Memória persistente:** cada agente acumula padrões aprendidos entre sessões (MEMORY.md)
- **Governança:** um modelo claro de autoridade define quem pode fazer o quê
- **Evolução controlada:** versionamento semântico e stories rastreiam a evolução do framework
- **Fronteira framework/usuário:** o manifesto define exatamente o que é framework e o que é conteúdo do usuário

---

## Arquitetura de Agentes

### Dois Tipos de Agentes

```
@kairos (governança do framework)
      ↓ autoridade sobre
squads/* (trabalho operacional — definido pelo usuário por instância)
      ↓ implementado por
Claude Code na conversa principal (constrói e mantém o Kairos)
```

**@kairos — Governança:**
- Versiona o framework, cria squads, gerencia stories
- Emite gates de review (PASS/RESSALVA/BLOCK)
- Controle exclusivo de git push
- Implementa stories `type: instance` via `*implement`

**Agentes de squad — Operacionais:**
- Criados via `@kairos *new-squad`
- Especializados por domínio (análise, pontuação, geração, classificação)
- Operam dentro da autoridade definida em `squads/{squad}/rules/agent-authority.md`
- Memoria persistente em `.kairos-core/agents/{id}/MEMORY.md`

### Protocolo de Handoff

Ao completar uma fase, cada agente gera um handoff compacto (< 500 tokens) em `.kairos-core/runtime/handoffs/`. O próximo agente detecta o handoff na ativação e sugere o próximo comando automaticamente.

```yaml
handoff:
  from_agent: "{agente que completou}"
  to_agent: "{próximo agente}"
  last_command: "{último comando}"
  context: { output_file, totais, insight_principal }
  next_action: "{o que o agente entrante deve fazer}"
```

---

## Modelo de Governança

### Camadas de Imutabilidade

```
L1 — Fundação    (não modifica sem bump MAJOR + justificativa)
L2 — Controlado  (apenas @kairos, exige story MINOR/MAJOR)
L3 — Gerenciado  (governança normal, pode ser PATCH)
L4 — Volátil     (efêmero, gitignored, sem versionamento)
```

A classificação de cada arquivo é declarada em `.kairos-core/manifest.yaml`. Path não determina camada — o manifesto sim.

### Fronteira Framework/Usuário

O manifesto é autoritativo. Regra default-deny:

> Se um arquivo **não** está no manifesto → é do usuário → não pode ser tocado por updates do framework.

Arquivos mistos usam blocos `<!-- KAIROS-MANAGED-START -->` (markdown) ou `owned_keys` (YAML/JSON) para demarcar o que é framework.

### Versionamento Semântico

```
PATCH  — correção, ajuste de instrução, MEMORY.md
MINOR  — novo agente, nova task, nova rule (exige story)
MAJOR  — novo squad, breaking change (exige story)
```

Autoridade exclusiva de versionamento: `@kairos *version` / `@kairos *pre-push`.

---

## Stack de Referência

O Kairos foi projetado para rodar sobre esta stack — instâncias podem adaptar, mas esta é a configuração canônica:

| Componente | Valor de referência |
|------------|---------------------|
| Runtime | Node.js (ESM, `"type": "module"`) |
| Linguagem | TypeScript |
| AI SDK | `@anthropic-ai/sdk` |
| Modelo padrão | `claude-sonnet-4-6` |
| Runner | `tsx` (sem compilação) |
| Claude Code | Versão atual (CLI + SDK) |

Integrações externas (n8n, Supabase, Google Sheets, etc.) são definidas por squad — não são parte da stack do framework.

---

## Estrutura de Diretórios

```
.kairos-core/
  agents/       # Memória persistente por agente (MEMORY.md) — user-content
  tasks/        # Tasks de governança (kairos-*) e operacionais (squad-*)
  data/         # kairos-kb.md, workers.yaml, dados de configuração
  docs/         # Documentação do framework: scope.md, data-flow.md, agent-standards.md
  templates/    # Scaffolds para squads e agentes
  constitution.md  # Princípios não-negociáveis (L1)
  manifest.yaml    # Fonte autoritativa de ownership (L1)
  runtime/      # Handoffs e logs (L4, gitignored)

.claude/
  commands/kairos/agents/  # Personas completas (YAML-in-Markdown)
  hooks/                   # PreCompact e PreToolUse hooks
  rules/                   # Rules cross-cutting (lifecycle, authority, handoff, layers)

src/
  agents/  # Scripts TypeScript de computação pura (sem AI inline)
  tools/   # Utilitários compartilhados (claude.ts, fs, etc.)

squads/
  {squad}/
    squad.yaml      # Manifesto do squad
    agents/         # Definições leves dos agentes
    tasks/          # Tasks operacionais do squad
    workflows/      # Pipeline documentado
    rules/          # Regras específicas do squad
```

---

## Princípios de Design

1. **IDS — Reutilizar > Adaptar > Criar:** antes de criar um novo artefato, verificar se algo existente cobre o caso
2. **Clareza sobre elegância:** código simples e direto; sem abstrações prematuras
3. **Governança explícita:** toda mudança estrutural gera bump de versão + entrada no CHANGELOG
4. **Fronteira clara:** framework e conteúdo do usuário são separados pelo manifesto — sem ambiguidade
5. **Handoffs compactos:** a troca de contexto entre agentes usa artefatos < 500 tokens

---

## Change Log

| Versão | Data | Mudança |
|--------|------|---------|
| 1.0 | 2026-04-16 | Criação inicial — escopo e arquitetura do framework (story 3.7) |
