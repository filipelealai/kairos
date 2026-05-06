# Epic 6 — Kairos como Serviço — Acesso Multi-usuário via MCP

**Status:** In Progress
**Objetivo:** Tornar a instância do Kairos acessível a múltiplos membros do time sem exigir conhecimento de git, instalação local do framework, ou cópias divergentes do repo, mantendo `filipe-instance` como única fonte de verdade.

---

## Descrição

Hoje o Kairos é uma ferramenta local: cada usuário precisa de Claude Code instalado, repo clonado, autenticação própria e fluência mínima em git para usar os squads. Isso impede que membros não-técnicos da equipe consumam os squads operacionais (cold-prospecting, sales-pipeline, client-onboarding) que poderiam acelerar significativamente o trabalho deles.

Este epic transforma o Kairos em um **serviço acessível** — implantado em VPS dedicada, sincronizado automaticamente com `filipe-instance`, e exposto via Model Context Protocol (MCP) para que qualquer cliente Claude (Desktop, web com integrações, eventualmente APIs próprias) possa consumir as capacidades operacionais sem fricção técnica.

A escolha pelo MCP — protocolo aberto da Anthropic para expor contexto e ferramentas a clientes Claude — alinha o Kairos com a direção do ecossistema, mantém a identidade dos agentes (personas, memory, rules) intacta, e permite execução de scripts no servidor (TypeScript dos squads, integrações com Trello, Sheets, Drive) com o membro do time consumindo apenas o resultado.

A arquitetura é **escalonável por adição, não por modificação**: cada incremento adiciona um caminho de acesso sem desfazer os anteriores. Versão 1 entrega o servidor MCP funcionando para Claude Desktop; versões posteriores adicionam endpoint HTTP paralelo, integração n8n e canal WhatsApp, todas reaproveitando o mesmo contêiner e código base.

---

## Critério de Conclusão

- [ ] Contêiner Docker do servidor MCP rodando em produção no VPS (Easypanel)
- [ ] Sincronização automática com `filipe-instance` do repo privado funcionando sem intervenção manual
- [ ] Membros do time conectam Claude Desktop ao servidor MCP via configuração única e operam squads (cold-prospecting, sales-pipeline, client-onboarding) end-to-end
- [ ] Outputs gerados pelos agentes ficam disponíveis em Google Drive automaticamente
- [ ] Restrição operacional aplicada: membros consomem squads, mas não acessam comandos de governança do `@kairos` (sem desenvolvimento de framework ou instância via MCP)
- [ ] Documentação de setup do membro do time (instalação Claude Desktop + arquivo de config) completa e validada por usuário não-técnico

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| [6.1](../stories/6.1.story.md) | Kairos MCP Server v1 — Implementação (Código + Docker + Docs) | Done |
| [6.2](../stories/6.2.story.md) | Kairos MCP Server v1 — Deploy, Integração e Validação | Done |

---

## Plano de Evolução (Stories Candidatas)

A arquitetura é incremental. Cada versão é aditiva — adiciona caminho de acesso sem alterar o anterior.

### v1 — MCP Server + Claude Desktop *(Stories 6.1 + 6.2)*

A v1 foi dividida em duas stories durante a execução por uma razão prática: o caminho completo (código + deploy + Service Account + validação com time) tem dependências externas que não podem ser resolvidas em uma única sessão. Split permite validar e versionar o código antes do deploy.

**Story 6.1 — Implementação (Código + Docker + Docs):**
- Servidor MCP em Node.js usando `@modelcontextprotocol/sdk`
- Resources expostos: personas, rules, memory, templates de cada agente
- Prompts MCP: um por agente operacional (carrega contexto completo na invocação)
- Tools MCP: `execute_script`, `check_job`, `list_jobs`, `save_output`, `list_outputs`, `read_handoff`, `write_handoff`
- Autenticação por API key
- Restrição: agentes de governança (`@kairos`) não expostos
- Dockerfile + docker-stack.yml com labels Traefik para HTTPS
- Documentação completa para o time em `squads/team-setup.md`
- Plano operacional em `squads/ops/tasks/mcp-deploy.md`
- Smoke test local validando 10 agentes operacionais expostos, governança excluída

**Story 6.2 — Deploy, Integração e Validação:**
- Service Account no Google Cloud + pasta-raiz no Drive
- GitHub PAT pra acesso ao repo privado
- Secrets no Docker Swarm da VPS
- Build da imagem + deploy do stack via Easypanel
- Validação Traefik + Let's Encrypt
- Smoke test do MCP em produção
- **Validação end-to-end com membro real do time** — Claude Desktop conectado, agente executado, output no Drive

**Critério de conclusão da v1:** Story 6.2 com ≥ 1 validação end-to-end registrada por membro do time não-owner.

---

### v2 — Endpoint HTTP `/api` paralelo *(story candidata 6.3)*

**O que entrega:** rota HTTP simples no mesmo contêiner do MCP server, permitindo clientes que não falam protocolo MCP (n8n, scripts próprios, integrações futuras) consumirem os agentes via REST.

**Componentes adicionais:**
- Rota `POST /api/agent` no mesmo servidor: recebe `{agent, command, input}`, monta contexto, chama Claude API internamente, retorna resposta estruturada
- `ANTHROPIC_API_KEY` adicionado ao `.env` do contêiner (necessário porque agora o servidor faz a chamada generativa, não mais o cliente)
- Reutilização total da camada de carregamento de contexto e execução de tools já implementada em v1
- Rate limiting básico e logs de uso por chamada

**Por que separado:** em v1, o trabalho generativo é feito no Claude Desktop do membro (consumindo seu próprio plano). Em v2, abrir um caminho não-Claude implica que o servidor precisa pagar pelos tokens — é uma decisão de billing que merece ser explícita.

---

### v3 — Integração n8n *(story candidata 6.4)*

**O que entrega:** workflow n8n no VPS que orquestra chamadas ao endpoint `/api`, com lógica de roteamento (qual agente acionar), gestão de histórico de conversa e formatação de output.

**Componentes adicionais:**
- Workflow n8n: webhook de entrada → identificação de agente → chamada `/api` → upload de output ao Drive → resposta formatada
- Storage de histórico de conversa por usuário (n8n database ou Postgres)
- Template de roteamento: por canal, por prefixo, ou por menu de seleção
- Tratamento de erros e reconexões

**Por que separado:** o n8n adiciona complexidade de orquestração (estado, roteamento, formatação) que é ortogonal ao servidor MCP. Mantê-lo isolado permite que `/api` seja testado e usado por outras integrações sem depender de n8n.

---

### v4 — Canal WhatsApp via Evolution API *(story candidata 6.5)*

**O que entrega:** acesso aos squads via WhatsApp para membros do time que não usam (ou não querem usar) Claude Desktop. Caminho de máxima fricção zero.

**Componentes adicionais:**
- Workflow n8n estendido: receber mensagem da Evolution API → identificar remetente → chamar `/api` → responder via Evolution API
- Mensagens de status ("Processando…") para tarefas longas
- Mapping de número de telefone → identidade no Kairos
- Tratamento de desconexão da Evolution API (já comum em uso prolongado)
- Output duplo: link curto no WhatsApp + arquivo completo no Drive

**Por que separado:** WhatsApp é canal opcional. Time pode operar 100% no Claude Desktop. Adicionar WhatsApp implica manter Evolution API estável, lidar com sessão/auth, e UX de timeouts — trabalho real que vale ser tratado quando a necessidade for clara.

---

## Premissas Arquiteturais

1. **`filipe-instance` permanece o ponto de desenvolvimento** — push-dual continua: framework → `main` (público), instância → `kairos-pessoal/filipe-instance` (privado). VPS faz pull do privado.

2. **Runtime do VPS é efêmero do ponto de vista do framework** — `data/outputs/`, `runtime/handoffs/` vivem no disco do contêiner, são sincronizados para Drive, mas nunca voltam pro git. O VPS é consumidor, não produtor de commits.

3. **Restrição operacional é convencional, não técnica** — o servidor MCP não expõe os prompts de governança do `@kairos`, mas tecnicamente nada impede que sejam expostos no futuro. A restrição é decisão de design, não barreira de segurança.

4. **Cada caminho aditivo preserva os anteriores** — v2 não modifica v1, v3 não modifica v2, etc. Garante que mudanças de escopo não quebram acessos já em uso pelo time.

5. **Billing é distribuído por design em v1** — cada membro paga seu próprio plano Claude (Desktop). Apenas v2+ introduzem custo centralizado de Claude API no VPS.

---

## Dependências

- VPS com Easypanel já provisionada e operacional
- Repo `filipelealweb/kairos-pessoal` (privado) já configurado no push-dual
- Acesso administrativo ao Easypanel para criar novo contêiner
- Ao menos um membro do time disponível para validar setup do Claude Desktop

---

## Fora de Escopo deste Epic

- Publicação do servidor MCP como pacote reutilizável por outras instâncias Kairos (potencial Epic futuro de framework)
- Multi-tenant real (múltiplas instâncias Kairos compartilhando um servidor) — fora do problema que estamos resolvendo
- Substituição do Claude Code para desenvolvimento — o Claude Code permanece como ferramenta de desenvolvimento do framework e da instância (`@kairos`), o MCP server é só para consumo operacional
- Métricas de uso por membro, billing interno, controle de quotas — pode virar story futura se houver necessidade

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-29 | Epic criado — Story 6.1 em Draft, v2-v4 descritas como stories candidatas |
| 2026-04-29 | Story 6.1 iniciada — Epic In Progress |
| 2026-04-29 | Story 6.1 Fase 1 concluída — código MCP + Docker + docs do time + plano de deploy. Smoke test local OK. Fase 2 (deploy efetivo + Service Account + validação) aguarda ações do usuário. |
| 2026-04-29 | Story 6.1 re-escopada — split em 6.1 (Implementação: código + Docker + docs, agora In Review) + 6.2 (Deploy, Integração e Validação, em Draft). Plano v2/v3/v4 renumerado para 6.3/6.4/6.5. |
| 2026-04-30 | Story 6.1 Done (gate PASS confirmado, push-dual concluído). Story 6.2 *implement iniciado — status → In Progress. |
| 2026-04-30 | Story 6.2 *implement concluído — todos os ACs atendidos (com ressalva de validação UX por membro não-owner como follow-up). Pivot Service Account → OAuth user delegation no meio do ciclo (limitação Google Drive 2024). MCP server em produção em https://kairos.vendoteca.com com 10 agentes operacionais expostos, Drive sync funcional, Claude Desktop end-to-end validado. Status → In Review. |
| 2026-04-29 | Story 6.1 concluída — *pre-push: gate PASS confirmado, status → Done |
| 2026-05-05 | Story 6.2 concluída — *pre-push: gate confirmado, status → Done |
