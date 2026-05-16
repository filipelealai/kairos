---
kairos-owned: true
kairos-version: 4.2.0
---

# Constituição do Kairos

> Princípios não-negociáveis do framework. Nada aqui pode ser violado, contornado ou ignorado — por nenhum agente, em nenhum contexto.
> Mudanças exigem decisão arquitetural explícita e bump MAJOR de versão.

---

## I. Integração com Ferramentas Externas

**Kairos pode e deve usar ferramentas externas. A questão é como.**

1. **Hierarquia de integração** — ao interagir com um sistema externo, seguir esta ordem de preferência:
   - **Skills do Claude Code** — se existe uma skill para a tarefa, usá-la primeiro
   - **MCPs configurados** — ferramentas de integração registradas no projeto (n8n-mcp, supabase-mcp, etc.)
   - **Scripts TypeScript** — `src/agents/` para computação e chamadas HTTP quando não há skill/MCP disponível

2. **Ações com side effects são explícitas** — envio, escrita, deleção, disparo devem ser visíveis ao usuário e confirméveis antes de executar quando irreversíveis.

3. **Escopo de autoridade por squad** — cada squad define quais sistemas externos seus agentes têm autoridade para usar. Não existe autoridade implícita de um agente sobre sistemas de outro squad.

4. **Restrições operacionais são de squad, não de framework** — regras como "nunca enviar e-mail diretamente" ou "nunca escrever em certa fonte de dados" são contratos de um squad específico com suas integrações, não limitações do Kairos como framework.

## II. Controle de Versão e Push

5. **Somente `@kairos *push`** pode fazer `git push` — nenhum outro agente, nenhuma conversa principal.
6. Todo `git push` de arquivos de framework (story com `type: kairos-core`) **deve ser precedido de `@kairos *pre-push` com resultado PASS** na mesma sessão.
7. **Toda mudança estrutural no Kairos** (novo agente, nova task, nova rule, novo squad) **gera bump de versão** e entrada no `CHANGELOG.md`.
8. Bumps de versão são **exclusivos do `@kairos *version`** (standalone ou via modo contribuidor no `*push`) — nunca editar `core-config.yaml` ou `CHANGELOG.md` manualmente para versionar.

## III. Autoridade dos Agentes

9. A **matriz de autoridade** em `.kairos-core/rules/agent-authority.md` é vinculante — nenhum agente executa operação fora de seu escopo.
10. **`@kairos`** tem autoridade sobre todos os outros agentes, mas **não substitui** o trabalho operacional dos squads — governa, não executa.
11. Stories em `docs/stories/` rastreiam **desenvolvimento do framework Kairos** — outputs operacionais (emails, scores, relatórios) vão para `data/outputs/`.

## IV. Integridade dos Dados

12. Kairos **nunca inventa métricas, leads, scores ou e-mails** — dados gerados vêm sempre de fontes reais (webhook, scripts TS).
13. Outputs são **idempotentes por data** — regerar no mesmo dia sobrescreve; comportamento intencional.
14. Scripts TypeScript em `src/agents/` são a **única fonte de computação pura** — agentes de IA interpretam e orquestram, não recalculam manualmente.

## V. Evolução do Framework

15. Novas capacidades seguem o princípio **IDS: REUTILIZAR > ADAPTAR > CRIAR** (ver `.kairos-core/rules/ids-principles.md`).
16. Mudanças nas camadas L1 e L2 (ver `.kairos-core/rules/framework-layers.md`) **requerem justificativa explícita** e revisão de @kairos.
17. A constituição **não é editada** pelo executor — apenas @kairos pode propor mudanças, e apenas com bump MAJOR.

## VI. Fronteira Framework / Usuário

18. **O Kairos é a infraestrutura; squads, agentes e integrações são o que o usuário constrói com ela.** São coisas distintas. A identidade do framework não depende de nenhum squad específico, nenhuma skill ou integração particular.

19. **Artefatos de framework** (infraestrutura): `.kairos-core/`, `.kairos-core/rules/`, `.claude/commands/kairos/agents/`, hooks, tasks, templates, constituição. Estes definem o que o Kairos É. **`src/` é integralmente user-owned** — o manifesto é a fonte autoritativa; qualquer diretório não listado nele é conteúdo do usuário.

20. **Artefatos do usuário** (produtos do framework): squads em `squads/`, agents em `src/agents/`, skills em `.claude/skills/`, MCPs e integrações configuradas. Estes definem o que o usuário FAZ com o Kairos.

21. **Documentação de framework descreve o framework genericamente.** Squads, pipelines, skills e integrações específicos do usuário só aparecem em docs de framework a título de exemplo, rotulados explicitamente como tal. Nunca apresentados como parte da definição do framework.

22. **Ao versionar, revisar ou evoluir o Kairos**, `@kairos` não trata mudanças em conteúdo de squads do usuário como mudanças de framework — a menos que o framework em si tenha mudado (nova infraestrutura, nova rule, nova task de governança).

23. **Regressão proibida** — nenhuma revisão futura de docs, stories ou changelog deve reclassificar conteúdo do usuário como conteúdo de framework.

24. **O manifesto é autoritativo.** A fronteira framework/usuário é definida pelo arquivo `.kairos-core/manifest.yaml` — não por convenção de path, frontmatter ou localização de diretório. Um arquivo pertence ao framework **se e somente se** ele (ou uma seção declarada dele, no caso de arquivos mistos) está listado no manifesto. Frontmatter `kairos-owned: true` é marker visível, não fonte de verdade.

25. **Contrato de update (default-deny).** Qualquer mecanismo de atualização do Kairos (CLI futuro, operação de `@kairos`, script de manutenção) **só pode criar, substituir ou remover arquivos/seções listados no manifesto**. Arquivos fora do manifesto, ou conteúdo fora de blocos `<!-- KAIROS-MANAGED-... -->` em arquivos mistos, são do usuário e **nunca** podem ser tocados por um update.

26. **Origem de componentes reconhecida.** A arquitetura distingue três fluxos de origem para qualquer artefato: (a) **oficial shipped** — adicionado pelo instalador/updater do Kairos e listado no manifesto; (b) **user-criado** — adicionado pelo usuário após instalação, nunca listado; (c) **pré-existente (brownfield)** — presente antes da instalação, não listado no manifesto. Updates só tocam em (a). (b) e (c) são intocáveis por definição.

---

*Versão inicial criada em 2026-04-14. Princípios 24-26 adicionados em 2.0.0 (2026-04-15).*
