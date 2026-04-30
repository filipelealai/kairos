# mcp-deploy — Deploy do Kairos MCP Server na VPS

Plano de execução da **Fase 2** da Story 6.1. A Fase 1 (código + Dockerfile + docs) está concluída no repo. Esta task descreve os passos de deploy efetivo na VPS, configuração de Service Account e validação end-to-end.

**Pré-requisitos:**
- Story 6.1 com Fase 1 marcada como concluída no Execution Log
- DNS `kairos.vendoteca.com` apontando para VPS (✅ já feito)
- Acesso SSH à VPS como root
- Acesso administrativo ao Easypanel

---

## Passo 1 — Garantir que o repo está atualizado

```bash
@kairos *push   # leva o filipe-instance pro kairos-pessoal (privado) e o framework pro main
```

A Fase 2 depende do código da Fase 1 estar disponível em `kairos-pessoal/filipe-instance`.

---

## Passo 2 — Criar Personal Access Token do GitHub

O contêiner MCP precisa autenticar no `kairos-pessoal` (repo privado) para clonar e dar pull.

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) (ou Fine-grained)
2. Criar token com escopo: **`repo`** (read-only é suficiente)
3. Copiar o token — não há segunda chance de visualizá-lo
4. Guardar em local seguro

URL final que vai pro contêiner:
```
https://<TOKEN>@github.com/filipelealweb/kairos-pessoal.git
```

---

## Passo 3 — Criar Service Account no Google Cloud

### 3.1 — Criar projeto (se não houver)

1. https://console.cloud.google.com/projectcreate
2. Nome sugerido: `kairos-instance` ou usar projeto existente

### 3.2 — Habilitar Google Drive API

1. https://console.cloud.google.com/apis/library/drive.googleapis.com
2. Selecionar o projeto correto no dropdown do topo
3. Clicar em **Enable**

### 3.3 — Criar Service Account

1. https://console.cloud.google.com/iam-admin/serviceaccounts
2. **Create Service Account**
3. Nome: `kairos-mcp-server`
4. ID será gerado automaticamente: `kairos-mcp-server@{projeto}.iam.gserviceaccount.com`
5. **Create and continue** → pular concessão de roles (não precisa) → **Done**

### 3.4 — Gerar chave JSON

1. Clicar na Service Account criada
2. Aba **Keys** → **Add Key** → **Create new key**
3. Tipo: **JSON** → **Create**
4. Arquivo `.json` será baixado — **guardar em local seguro**
5. Esse arquivo NUNCA pode ir para o repo

### 3.5 — Compartilhar pasta do Drive com a Service Account

1. Criar (ou usar existente) pasta no Google Drive: ex `Kairos Outputs`
2. Botão direito → **Share** → adicionar e-mail da Service Account (o `kairos-mcp-server@...iam.gserviceaccount.com`)
3. Permissão: **Editor**
4. **Send** (sem notificação)
5. Copiar o **ID da pasta** da URL: `https://drive.google.com/drive/folders/<ID-AQUI>`

---

## Passo 4 — Gerar API key do servidor MCP

```bash
openssl rand -hex 32
```

Guardar a key em local seguro (1Password, etc.). Essa é a chave que vai ser distribuída aos membros do time.

---

## Passo 5 — Criar secrets no Docker Swarm da VPS

Via SSH na VPS:

```bash
# API key do MCP (cole quando pedir; Ctrl+D ao final)
echo -n "<api-key-gerada-no-passo-4>" | docker secret create kairos_mcp_api_key -

# URL do git com PAT embutido
echo -n "https://<github-pat>@github.com/filipelealweb/kairos-pessoal.git" | \
  docker secret create kairos_git_url -

# Service Account JSON (substituir pelo path do arquivo baixado no passo 3.4)
docker secret create kairos_drive_sa /caminho/local/service-account.json

# Verificar
docker secret ls | grep kairos
```

---

## Passo 6 — Build da imagem na VPS

Via SSH:

```bash
cd /tmp
git clone --branch filipe-instance --single-branch \
  https://<github-pat>@github.com/filipelealweb/kairos-pessoal.git kairos-build
cd kairos-build
docker build -f src/mcp-server/Dockerfile -t kairos-mcp:latest .
docker images kairos-mcp:latest
cd /tmp && rm -rf kairos-build
```

A imagem fica disponível localmente para o swarm.

---

## Passo 7 — Configurar GOOGLE_DRIVE_ROOT_FOLDER_ID

O `docker-stack.yml` referencia essa variável via interpolação. Antes do deploy:

```bash
export GOOGLE_DRIVE_ROOT_FOLDER_ID=<id-da-pasta-do-passo-3.5>
```

Ou criar como secret também:
```bash
echo -n "<id-da-pasta>" | docker secret create kairos_drive_folder_id -
```

(Se optar por secret, ajustar `docker-stack.yml` para ler de `_FILE`.)

---

## Passo 8 — Deploy do stack

Via SSH, no diretório onde o `docker-stack.yml` está:

```bash
# Baixar só o stack file:
curl -H "Authorization: token <github-pat>" \
  -o /tmp/kairos-stack.yml \
  https://raw.githubusercontent.com/filipelealweb/kairos-pessoal/filipe-instance/src/mcp-server/docker-stack.yml

# Deploy
cd /tmp
GOOGLE_DRIVE_ROOT_FOLDER_ID=<id> \
  docker stack deploy -c kairos-stack.yml kairos --with-registry-auth

# Verificar
docker stack services kairos
docker service logs kairos_kairos-mcp --tail 50 -f
```

Esperado nos logs:
```
[...] INFO Starting Kairos MCP Server
[...] INFO Cloning repo
[...] INFO Clone complete
[...] INFO Operational agents loaded {"count":10,"excluded_master":"kairos"}
[...] INFO Kairos MCP Server listening {"port":3333}
```

---

## Passo 9 — Validar Traefik + HTTPS

O Traefik vai pegar os labels do serviço automaticamente e provisionar cert Let's Encrypt.

```bash
# Aguardar ~30s para o cert ser emitido
curl -fsS https://kairos.vendoteca.com/health
# Esperado: {"ok":true,"version":"1.0.0","ts":"..."}
```

Se der erro de cert: verificar que o Traefik está com `certresolver=letsencrypt` configurado e que a porta 80 está livre/aberta na VPS para o challenge HTTP-01.

---

## Passo 10 — Smoke test do MCP

```bash
curl -X POST https://kairos.vendoteca.com/mcp \
  -H "Authorization: Bearer <api-key>" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke-test","version":"0"}}}'
```

Resposta esperada: JSON com capabilities e info do servidor.

```bash
# Listar prompts (agentes operacionais)
curl -X POST https://kairos.vendoteca.com/mcp \
  -H "Authorization: Bearer <api-key>" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"prompts/list","params":{}}'
```

Esperado: lista com `kairos-cold-prospecting-email-writer`, `kairos-client-onboarding-brief-extractor`, etc. **Não deve aparecer nenhum prompt do `@kairos`**.

---

## Passo 11 — Validação com membro do time

1. Distribuir API key + link do `squads/team-setup.md` ao primeiro membro
2. Acompanhar setup do Claude Desktop dele
3. Pedir pra ele rodar um pipeline simples: `kairos-client-onboarding-brief-extractor` com input fictício de uma empresa
4. Confirmar que:
   - O prompt aparece no menu do Claude Desktop
   - O agente carrega persona corretamente
   - O `save_output` funciona (output aparece no Drive)
5. Documentar a validação no Execution Log da Story 6.1

---

## Passo 12 — Fechar a story

Após validação OK:

```
@kairos *review 6.1   # gate PASS esperado
@kairos *pre-push     # bump de versão (MINOR)
@kairos *push         # leva pro filipe-instance + main
```

---

## Rollback de emergência

Se o deploy quebrar:

```bash
# Remover stack
docker stack rm kairos

# Remover imagem
docker rmi kairos-mcp:latest

# Remover secrets se quiser regenerar
docker secret rm kairos_mcp_api_key kairos_drive_sa kairos_git_url
```

A pasta no Google Drive e o repo no GitHub não são afetados pelo rollback.

---

## Custos esperados em produção (v1)

- VPS: já paga, sem custo adicional
- Google Cloud: free tier cobre Drive API uso pequeno
- Anthropic API: **zero** em v1 (cada membro usa seu próprio Claude Desktop)
- Tráfego: desprezível (só JSON-RPC)
