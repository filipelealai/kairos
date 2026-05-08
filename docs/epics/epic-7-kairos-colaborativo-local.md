# Epic 7 — Kairos Colaborativo Local — Instalável, Atualizável, Compartilhável

**Status:** Draft
**Objetivo:** Tornar o Kairos consumível por times sem servidor central, sem VPS, sem OAuth de terceiros — cada membro tem sua instância local, outputs sincronizam por app de nuvem nativo, squads são compartilháveis sem Git, e o framework é instalável/atualizável/desinstalável por leigos.

---

## Descrição

O Epic 6 ("Kairos como Serviço") atacou o problema de adoção por membros não-técnicos via servidor MCP em VPS. A abordagem funciona, mas trouxe complexidade significativa: Docker, Easypanel, OAuth Drive (com pivot Service Account → user delegation), Bearer token, sync Git por cron, billing centralizado em v2+, manutenção de infra.

Este epic propõe uma alternativa simétrica e mais simples: em vez de um servidor central, **cada pessoa do time roda sua própria instância local do Kairos**, usando seu próprio Claude Code (terminal, IDE ou aba "Claude Code" do Claude Desktop). A colaboração emerge de três mecanismos plug-and-play:

1. **Outputs identificáveis por instância** — `KAIROS_INSTANCE_NAME` no nome do arquivo evita colisão quando dois membros rodam o mesmo agente no mesmo dia.
2. **Sync de outputs via app de nuvem nativo** — symlink `data/outputs/ → /Drive/Kairos Outputs/` aproveita Google Drive Desktop, OneDrive ou Dropbox para sincronização. Zero código de auth.
3. **Squads exportáveis/importáveis em arquivo único** — `*export-squad` empacota um squad com dependências em `.tar.gz`/`.zip`, distribuído por qualquer canal (e-mail, Drive, pendrive), e `*import-squad` instala na instância destino.

Para viabizar adoção por leigos, o framework ganha:
- **`install.sh` / `install.ps1`** — instalador interativo cross-platform com UX amigável (banner ASCII, elicitação humana, validação de pré-requisitos, sem dependência de Git).
- **`@kairos *update`** + **SessionStart hook** — atualizações via tarball do GitHub (sem Git no cliente), com alerta automático no início de sessão se houver versão nova.
- **`uninstall.sh` / `uninstall.ps1`** — remove apenas conteúdo declarado no manifesto, preserva opcionalmente outputs e `.env`, limpa pastas vazias.

O MCP server do Epic 6 não é descontinuado por esta entrega — coexiste em paralelo. A decisão de aposentar fica para depois.

---

## Critério de Conclusão

- [ ] Membro do time consegue instalar Kairos em máquina nova (Linux, Mac ou Windows) sem usar Git, sem editar arquivo de config manualmente, em < 10 min de wall-clock
- [ ] Dois membros operando o mesmo squad no mesmo dia geram outputs distintos identificáveis por nome
- [ ] Membro consegue compartilhar um squad funcional (com dependências externas) com outro membro via arquivo único, sem usar Git
- [ ] Atualização do framework (`@kairos *update`) funciona em instância sem Git instalado, preservando todos os arquivos user-owned
- [ ] Desinstalação remove 100% dos arquivos framework-owned do manifesto, preserva outputs/`.env` quando solicitado, não deixa pastas vazias
- [ ] Documentação `.kairos-core/docs/install.md` validada por usuário não-técnico em Linux, Mac e Windows

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| [7.1](../stories/7.1.story.md) | `KAIROS_INSTANCE_NAME` a nível de framework + naming canônico | Done |
| [7.2](../stories/7.2.story.md) | Tagging automático no `*pre-push` + backfill one-shot | Done |
| [7.3](../stories/7.3.story.md) | `@kairos *update` + SessionStart hook de version-check | Done |
| [7.4](../stories/7.4.story.md) | Cloud sync via symlink + `@kairos *configure-cloud` | Done |
| [7.5](../stories/7.5.story.md) | `@kairos *export-squad` / `*import-squad` + dependências externas | Done |
| [7.6](../stories/7.6.story.md) | Installer / Uninstaller cross-platform + docs | Done |

---

## Premissas Arquiteturais

1. **Sem dependência de Git para usuário final.** Instalação e update operam via tarball/zipball do GitHub. Git só é exigido para quem mantém ou contribui com o framework.
2. **Manifesto é fonte autoritativa do que instalar.** Tarball traz o repo inteiro, mas instalador/updater consulta `manifest.yaml` da tag e copia apenas `owned_files` + `owned_sections` + `sync_files` declarados em story.
3. **Tags semver no `main` de `filipelealweb/kairos` são a fonte de verdade do `*update`.** Updater nunca puxa HEAD. Tagging é automático via `*pre-push`, extraído do `CHANGELOG.md`.
4. **Sync de nuvem é delegado ao app oficial do provedor.** Kairos só cria symlink. Sem OAuth, sem Workspace pago, sem refresh tokens.
5. **Squads carregam suas próprias dependências externas** (CLIs, MCPs) via campo `external_dependencies` em `squad.yaml`. Export embute esse manifesto; import valida e oferece instalação assistida.
6. **Brownfield install** (instalar em pasta de projeto pré-existente) — fora de escopo deste epic.

---

## Dependências

- Acesso de manutenção a `filipelealweb/kairos` (público) para criar tags retroativas no backfill da Story 7.2.
- Nenhuma dependência de infra externa (sem VPS, sem Docker, sem Cloud account do framework).

---

## Fora de Escopo deste Epic

- Substituição do MCP server do Epic 6 (decisão de descontinuar fica para depois).
- Brownfield install em pastas pré-existentes.
- GUI/wizard gráfico de instalação (instalador é terminal-based, com UX cuidadosa via ASCII e elicitação amigável).
- Suporte a outras forges além de GitHub para `update_source`.

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-05-05 | Epic criado a partir de plano alternativo ao Epic 6 — todas as 6 stories em Draft |
| 2026-05-05 | Story 7.1 concluída — In Review |
| 2026-05-05 | Story 7.2 iniciada — In Progress |
| 2026-05-05 | Story 7.2 concluída — In Review |
| 2026-05-05 | Stories 7.1 e 7.2 — *pre-push: gate confirmado, status → Done |
| 2026-05-05 | Story 7.3 iniciada — In Progress |
| 2026-05-05 | Story 7.3 concluída — In Review |
| 2026-05-06 | Story 7.3 reaberta — smoke test expôs ausência de json_keys, novos ACs adicionados |
| 2026-05-06 | Story 7.3 concluída (rodada 2) — In Review |
| 2026-05-06 | Story 7.4 iniciada — In Progress |
| 2026-05-06 | Story 7.4 concluída — In Review |
| 2026-05-06 | Stories 7.3 e 7.4 — *pre-push: gate confirmado, status → Done |
| 2026-05-06 | Story 7.5 iniciada — In Progress |
| 2026-05-06 | Story 7.5 concluída — In Review |
| 2026-05-06 | Story 7.6 iniciada — In Progress |
| 2026-05-06 | Story 7.6 concluída — In Review |
| 2026-05-08 | Story 7.6 — smoke tests concluídos (4 cenários ✅: IA + manual + tarball em branch de teste); status In Review confirmado |
| 2026-05-08 | *pre-push: gate confirmado para 7.5 e 7.6 — status → Done; version bump 3.14.0 → 3.15.0 |
