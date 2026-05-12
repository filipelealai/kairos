---
kairos-owned: true
kairos-version: 4.2.0
---

## Resumo

<!-- 1-2 linhas descrevendo o que este PR faz e por quê -->

## Tipo de mudança

- [ ] `kairos-core` — modifica o núcleo do framework (rules, tasks, hooks, manifest, templates)
- [ ] `docs` — documentação pura, sem impacto funcional
- [ ] `bugfix` — corrige comportamento incorreto
- [ ] `user-content` — conteúdo do usuário (squads, dados, plugins)

## Story relacionada

<!-- Link para a story em docs/stories/ se aplicável, ex: [5.17](docs/stories/5.17.story.md) -->
<!-- Se não há story associada, escreva "N/A" -->

## Checklist

- [ ] `.kairos-core/manifest.yaml` atualizado (se novos arquivos framework-owned foram criados)
- [ ] `@kairos *pre-push` retornou PASS (obrigatório antes de PR — verifica gate de review e referências)
- [ ] `@kairos *push` executado (inclui doctor via `*version`, bump, transição Done e commit)

**Se há story `type: kairos-core` associada:**
- [ ] `@kairos *review {id}` retornou PASS ou RESSALVA
- [ ] `@kairos *version` executado (bump de versão com `*doctor` como Passo 1)
  - Pode ser executado standalone ou via prompt "modo contribuidor" no `*push`
- [ ] `CHANGELOG.md` atualizado com a nova versão
- [ ] Frontmatter `kairos-owned: true` + `kairos-version` presentes nos novos arquivos framework (se aplicável)

> CI `version-guard` verifica automaticamente: bump (Check A), frontmatter (Check B), CHANGELOG (Check C) e gate de review (Check D) para PRs com arquivos de framework.
