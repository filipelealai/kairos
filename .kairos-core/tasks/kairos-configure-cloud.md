---
kairos-owned: true
kairos-version: 4.1.0
id: kairos-configure-cloud
title: Configurar Sync de Outputs para Nuvem via Symlink
agent: kairos
command: "*configure-cloud [--reset]"
version: 2
---

# Task: kairos-configure-cloud

## Propósito

Criar um symlink de `data/outputs/` para uma pasta local sincronizada por app de nuvem (Google Drive Desktop, OneDrive, Dropbox, iCloud) ou rclone, permitindo que outputs do Kairos apareçam automaticamente na nuvem compartilhada com o time. Zero OAuth — o sync é delegado inteiramente ao app oficial do provedor ou ao mount FUSE do rclone.

---

## Modos de Execução

### `*configure-cloud` — Configurar sync

**Passo 1 — Detecção automática de provedores**

Detectar apps de nuvem instalados conforme o OS:

**macOS:**
- iCloud: `~/Library/Mobile Documents/com~apple~CloudDocs`
- Google Drive: `~/Library/CloudStorage/GoogleDrive-*/` (um entry por conta) e `~/Google Drive`
- OneDrive: `~/Library/CloudStorage/OneDrive-*/` e `~/OneDrive`
- Dropbox: `~/Dropbox` e `~/Library/CloudStorage/Dropbox`

**Windows:**
- Google Drive: `%USERPROFILE%\Google Drive\Meu Drive`, `%USERPROFILE%\Google Drive\My Drive`, `G:\Meu Drive`, `H:\Meu Drive`
- OneDrive: `%OneDrive%` (variável de ambiente) e `%USERPROFILE%\OneDrive*`
- Dropbox: `%LOCALAPPDATA%\Dropbox\info.json` (lê o campo `personal.path`) e `%USERPROFILE%\Dropbox`

**Linux / WSL:** sem detecção de apps nativos — oferecer diretamente o fluxo rclone.

Exibir resultado da varredura:

```
Varredura concluída. Apps de nuvem encontrados:
  1) Google Drive (/Users/joao/Library/CloudStorage/GoogleDrive-joao@gmail.com)
  2) Dropbox (/Users/joao/Dropbox)
  3) Configurar com rclone
  4) Outro/Custom (informar path manualmente)
  5) Pular e configurar depois com `@kairos *configure-cloud`

Escolha: _
```

Quando múltiplos roots do mesmo provedor forem encontrados (ex: dois `GoogleDrive-{conta}` no Mac), listar cada um como entry separado.

Se nenhum provider for detectado (e OS ≠ Linux/WSL):

```
Nenhum app de nuvem detectado automaticamente.

  1) Instalar app de nuvem e retornar
  2) Configurar com rclone
  3) Informar path manualmente
  4) Pular e configurar depois com `@kairos *configure-cloud`
```

Se OS = Linux/WSL: pular a varredura e exibir diretamente:

```
Em Linux/WSL o sync é feito via rclone (mount FUSE).

  1) Configurar com rclone
  2) Pular e configurar depois com `@kairos *configure-cloud`
```

---

**Passo 1.5 (condicional) — Wizard rclone**

Executar somente quando OS = Linux/WSL OU o usuário selecionou "Configurar com rclone".

**1.5.1 — Verificar rclone instalado**

```bash
command -v rclone
```

Se ausente:
```
rclone não encontrado.

  macOS:      brew install rclone
  Linux/WSL:  curl https://rclone.org/install.sh | sudo bash

Instale e execute `@kairos *configure-cloud` novamente.
```
HALT.

**1.5.2 — Listar remotes**

```bash
rclone listremotes
```

Se vazio:
```
Nenhum remote rclone configurado.

Execute: rclone config
(OAuth interativo — siga as instruções na tela)

Após configurar, execute `@kairos *configure-cloud` novamente.
```
HALT.

Se houver remotes, exibir menu numerado e pedir escolha.

**1.5.3 — Verificar mount ativo**

```bash
mount | grep -E 'type fuse\.rclone'
```

Filtrar por nome do remote escolhido. Se nenhum mount ativo:

```
Nenhum mount ativo para '{remote}'.

Para montar, execute em outro terminal:
  mkdir -p ~/rclone/{remote}
  rclone mount {remote}: ~/rclone/{remote} \
    --vfs-cache-mode writes --dir-cache-time 5s \
    --poll-interval 5s --daemon

Pressione Enter após montar (ou Ctrl+C para cancelar).
```

Aguardar Enter. Verificar novamente. Se ainda ausente: HALT com instrução de configurar depois.

**1.5.4 — Registrar provider e mount point**

Extrair mount point: `mount | grep -E 'type fuse\.rclone' | grep {remote} | awk '{print $3}'`

Provider gravado em `cloud-sync.json` como `rclone:{remote}` (ex: `rclone:drive`).

**1.5.5 — Oferecer persistência do mount**

Verificar systemd: `systemctl is-system-running`

Se systemd ativo (Linux puro ou WSL2 com systemd habilitado):

```
systemd detectado. Deseja persistir o mount após reboot?
  1) systemd --user (sem sudo, recomendado)
  2) system-wide (com sudo)
  3) Pular
```

Opção 1 — criar unit em `~/.config/systemd/user/rclone-kairos-{remote}.service`:

```ini
[Unit]
Description=rclone mount — kairos {remote}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStartPre=/bin/mkdir -p {mount_point}
ExecStart=/usr/bin/rclone mount {remote}: {mount_point} --vfs-cache-mode writes --dir-cache-time 5s --poll-interval 5s
ExecStop=/bin/fusermount -uz {mount_point}
Restart=on-failure

[Install]
WantedBy=default.target
```

Executar: `systemctl --user daemon-reload && systemctl --user enable {unit} && systemctl --user start {unit}`

Se systemd ausente (WSL2 sem systemd ou Linux sem init systemd):

```
systemd não está ativo.
  1) Adicionar bloco ao ~/.bashrc (funciona apenas em terminais interativos — não funciona com hooks/cron)
  2) Ver instruções para habilitar systemd no WSL
  3) Pular
```

Opção 1 — adicionar ao `~/.bashrc`, verificando marcador antes (idempotente):

```bash
# Checar marcador antes de escrever (idempotência)
grep -q "# KAIROS-RCLONE-MOUNT" ~/.bashrc || cat >> ~/.bashrc <<'BLOCK'

# KAIROS-RCLONE-MOUNT
if ! mount 2>/dev/null | grep -qE "type fuse\.rclone.*{mount_point}|{mount_point}.*fuse\.rclone"; then
  mkdir -p "{mount_point}"
  rclone mount {remote}: "{mount_point}" \
    --vfs-cache-mode writes --dir-cache-time 5s \
    --poll-interval 5s --daemon 2>/dev/null || true
fi
# KAIROS-RCLONE-MOUNT-END
BLOCK
```

Avisar que `.bashrc` só executa em terminais interativos — **não funciona com hooks ou cron**.

Opção 2 — exibir instruções para habilitar systemd no WSL e HALT:

```
Para habilitar systemd no WSL:
1. Edite (como root) /etc/wsl.conf e adicione:
   [boot]
   systemd=true
2. No Windows, execute: wsl --shutdown
3. Reabra o WSL e execute: @kairos *configure-cloud
```

---

**Passo 2 — Subpasta**

Após o root detectado (ou mount rclone confirmado), perguntar o nome da subpasta:

```
Qual nome de subpasta usar dentro de:
  {root}
[Kairos Outputs] → _
```

`symlink_target = {root}/{subfolder}`. Criar a subpasta se não existir:
```bash
mkdir -p "{symlink_target}"
```

A opção "Outro/Custom" (Passo 1) permite digitar path absoluto completo. Nesse caso, o path informado é tratado diretamente como `symlink_target` — mas o wizard ainda pergunta a subpasta dentro dele se desejar (pular com Enter usa o path como está).

---

**Passo 3 — Validar caminho**

1. Verificar que o diretório existe: `test -d "{symlink_target}"`
   → Se não existir: perguntar se deseja criá-lo. Se sim: `mkdir -p "{symlink_target}"`. Se não: HALT.
2. Verificar gravabilidade: tentar escrever arquivo de teste temporário.
   → Se não gravável: informar o problema e HALT.

---

**Passo 4 — Provedor declarado (apenas quando ambíguo)**

Este passo só é executado quando:
- Múltiplos roots do mesmo provedor foram encontrados (ex: dois `GoogleDrive-{conta}` no Mac) **e** o usuário ainda não escolheu entre eles no Passo 1, OU
- O Passo 1 retornou "Outro/Custom" e o provedor não é inferível do caminho

Caso contrário (provider detectado inequivocamente no Passo 1 ou wizard rclone concluiu): pular.

Quando executado:

```
Provedor detectado: {provedor inferido do path, ou "desconhecido"}
Isso está correto? (s/n — se não, informe o nome do provedor)
```

---

**Passo 5 — Migração de conteúdo existente**

Verificar se `data/outputs/` existe como diretório (não symlink) com conteúdo:

```bash
[ -d "data/outputs" ] && [ ! -L "data/outputs" ] && [ "$(ls -A data/outputs 2>/dev/null)" ]
```

Se sim, perguntar:

```
data/outputs/ existe e tem conteúdo. Deseja mover esses arquivos para
{symlink_target} antes de criar o symlink? (s para mover / n para deixar apenas no destino)
```

- Se `s`: `mv data/outputs/* "{symlink_target}/"`
- Se `n`: prosseguir sem mover

Remover `data/outputs`: `rm -rf data/outputs`

**Idempotência (symlink existente):**

Se `data/outputs` já é um symlink:

```bash
_old=$(readlink -f data/outputs 2>/dev/null || readlink data/outputs)
```

- Se `$_old == {symlink_target}`: exibir "Symlink já aponta para {symlink_target} — nada a fazer." e encerrar com sucesso.
- Se diferente: exibir destino atual e confirmar reconfiguração antes de `rm data/outputs`.

---

**Passo 6 — Criar symlink**

```bash
ln -s "{symlink_target}" data/outputs
```

**No Windows:** se o comando falhar com erro de permissão, exibir:

```
⚠️  Falha ao criar symlink no Windows.

Para criar symlinks no Windows você precisa de um dos seguintes:
  1. Developer Mode habilitado:
     Configurações → Privacidade e segurança → Para desenvolvedores → Ativar "Modo Desenvolvedor"
  2. Executar o terminal como Administrador e repetir o comando.
```

HALT sem fallback automático.

---

**Passo 7 — Validar symlink (com tolerância a cold start)**

Determinar se é necessário polling baseado no `provider`:

- **Requer polling:** `rclone:*` ou qualquer provedor cloud reconhecido (Google Drive, OneDrive, Dropbox, iCloud)
- **Sem polling (validação rápida):** `custom` ou paths locais não-cloud

**Para provedores cloud / rclone — polling com backoff:**

Tentar escrever e ler arquivo de teste. Sequência de espera entre tentativas: `1s → 2s → 5s → 10s → 15s` (total ≤ 30s, máximo 5 tentativas).

```bash
_delays=(0 1 2 5 10 15)
_success=false
for _d in "${_delays[@]}"; do
  [ "$_d" -gt 0 ] && sleep "$_d"
  if echo "kairos-sync-test" > data/outputs/.sync-test 2>/dev/null \
     && grep -q "kairos-sync-test" data/outputs/.sync-test 2>/dev/null; then
    rm -f data/outputs/.sync-test
    _success=true
    break
  fi
done
```

Tick de sucesso em qualquer tentativa → PASS imediato.

Se todas as tentativas falharem (janela de 30s esgotada):

```
⚠️  Timeout na validação do symlink (provável cold start do mount).

O mount pode estar dormindo. Tente:
  echo "teste" > data/outputs/.sync-test && cat data/outputs/.sync-test

Se funcionar, o sync está operacional. Caso contrário, verifique o mount
e execute `@kairos *configure-cloud` novamente, ou `@kairos *doctor` para diagnóstico.
```

Remover symlink criado (`rm data/outputs`), restaurar diretório (`mkdir -p data/outputs`) e HALT.

**Para custom / local — validação rápida (sem polling):**

```bash
echo "kairos-sync-test" > data/outputs/.sync-test \
  && cat data/outputs/.sync-test \
  && rm data/outputs/.sync-test
```

→ Se falhar: informar erro, remover symlink, restaurar diretório e HALT.

**Resolução de symlinks:**
- Para testar acessibilidade física: `readlink -f data/outputs` (resolve o destino real)
- Para reportar ao usuário: `realpath -L data/outputs` (preserva o caminho do symlink, não troca pelo target)
- PowerShell equivalente: `Resolve-Path` para resolução; `(Get-Item data\outputs).Target` para exibição do target

---

**Passo 8 — Salvar configuração**

Criar/atualizar `.kairos-core/runtime/cloud-sync.json`:

```json
{
  "configured": true,
  "symlink_target": "{symlink_target expandido}",
  "provider": "{provedor}",
  "configured_at": "{ISO 8601}"
}
```

Onde `provider` é:
- `"Google Drive"`, `"OneDrive"`, `"Dropbox"`, `"iCloud"` para apps nativos
- `"rclone:{remote}"` para rclone (ex: `"rclone:drive"`)
- `"custom"` para path manual

---

**Passo 9 — Reportar sucesso**

```
✅ Cloud sync configurado com sucesso!

  Symlink criado:  data/outputs/ → {symlink_target}
  Provedor:        {provedor}

  A partir de agora, todos os outputs gerados pelos agentes Kairos
  serão automaticamente sincronizados para {provedor}.

  Para desfazer: @kairos *configure-cloud --reset
```

---

### `*configure-cloud --reset` — Remover symlink e restaurar pasta local

**Passo 1 — Verificar configuração**

Verificar se `data/outputs` é um symlink (`test -L data/outputs`).
Se não for symlink: informar "data/outputs não é um symlink — nada a desfazer." e HALT.

**Passo 2 — Ler destino atual**

```bash
readlink data/outputs
```

Confirmar com o usuário:

```
Symlink atual: data/outputs/ → {destino}
Deseja remover o symlink e restaurar data/outputs/ como pasta local?
O conteúdo em {destino} NÃO será deletado — apenas o symlink será removido. (s/n)
```

Se `n`: HALT.

**Passo 3 — Remover symlink e restaurar**

```bash
rm data/outputs
mkdir -p data/outputs
```

**Passo 4 — Atualizar configuração**

Atualizar `.kairos-core/runtime/cloud-sync.json`:

```json
{
  "configured": false,
  "symlink_target": null,
  "provider": null,
  "reset_at": "{ISO 8601}"
}
```

**Passo 5 — Reportar**

```
✅ Symlink removido. data/outputs/ restaurada como pasta local.

  O conteúdo sincronizado em {destino} permanece intacto.
  Para reconfigurar: @kairos *configure-cloud
```

---

## Notas Técnicas

- Symlinks em macOS/Linux requerem apenas permissão de escrita no diretório pai — sem privilégio especial.
- No Windows, symlinks fora do Developer Mode exigem privilégio de administrador. A task não tenta workarounds (decisão arquitetural).
- `.kairos-core/runtime/cloud-sync.json` é L4 (volátil, gitignored) — não entra no manifesto.
- O `*doctor` lê `cloud-sync.json` para validar integridade do symlink após configuração.
- Cold start de mounts rclone pode levar 10–30s. O polling de validação (Passo 7) cobre essa janela.
- Idempotência: rodar duas vezes seguidas não duplica `.bashrc`, não quebra symlink existente, reescreve `cloud-sync.json` com novo `configured_at`.
