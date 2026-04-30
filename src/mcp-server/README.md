# Kairos MCP Server

Servidor MCP (Model Context Protocol) que expõe os agentes operacionais do Kairos para clientes Claude (Desktop, etc.) sem exigir instalação local do framework.

## O que ele faz

- Clona o repo `kairos-pessoal` (branch `filipe-instance`) na inicialização
- Mantém-se sincronizado via git pull periódico (cron)
- Expõe cada agente operacional (não-`@kairos`) como **prompt MCP** que carrega contexto completo (persona + rules + memory + templates)
- Oferece **tools MCP** para executar scripts, salvar outputs, ler/gravar handoffs
- Faz upload duplo dos outputs: filesystem do contêiner + Google Drive

## Variáveis de ambiente

Ver raiz do repo: `.env.example` (seções `KAIROS_MCP_*` e `GOOGLE_DRIVE_*`).

Mínimo para subir:
```
KAIROS_MCP_API_KEY=<chave aleatória de 32+ chars>
KAIROS_SYNC_REMOTE_URL=https://<token>@github.com/filipelealweb/kairos-pessoal.git
KAIROS_SYNC_BRANCH=filipe-instance
```

Sem `GOOGLE_DRIVE_*` configurado, o upload pra Drive fica desligado (só salva local).

## Endpoints

- `GET /health` — health check (sem auth)
- `POST /mcp` — endpoint MCP (Bearer token via header `Authorization`)

## Execução local

```bash
npm install
KAIROS_MCP_API_KEY=dev-secret-key-min-16-chars KAIROS_SYNC_MODE=off KAIROS_REPO_PATH=$(pwd) npm run mcp
```

Em modo `KAIROS_SYNC_MODE=off`, o servidor usa o repo local existente sem clonar.

## Restrição de governança

Apenas agentes em `core-config.yaml > agents.squads` (com `status: active`) são expostos.
O agente `@kairos` (`agents.master`) é explicitamente excluído. Comandos de governança
(`*new-story`, `*implement`, `*push`, etc.) **não** são acessíveis via MCP.

## Estrutura

```
src/mcp-server/
├── index.ts           # entrypoint HTTP (Express + Streamable HTTP transport)
├── server.ts          # registro de prompts, resources e tools
├── config.ts          # validação de env vars (zod)
├── logger.ts          # logger simples
├── agent-registry.ts  # lista de agentes operacionais a partir do core-config
├── context-loader.ts  # monta system message do agente (persona + rules + memory + templates)
├── job-queue.ts       # estado in-memory de jobs assíncronos
├── git-sync.ts        # clone + pull periódico
└── drive-client.ts    # cliente Google Drive (Service Account)
```
