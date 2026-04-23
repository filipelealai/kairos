---
kairos-owned: true
kairos-version: 3.6.0
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
- [ ] `@kairos *doctor` retornou PASS
- [ ] `@kairos *review` retornou PASS ou RESSALVA (obrigatório se há story associada)
- [ ] `@kairos *pre-push` retornou PASS e fez commit válido (obrigatório antes de PR)
- [ ] `CHANGELOG.md` atualizado (obrigatório para MINOR e MAJOR; recomendado para PATCH)
- [ ] Frontmatter `kairos-owned: true` + `kairos-version` presentes nos novos arquivos framework (se aplicável)
