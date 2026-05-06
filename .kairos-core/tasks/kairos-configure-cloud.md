---
kairos-owned: true
kairos-version: 3.14.0
id: kairos-configure-cloud
title: Configurar Sync de Outputs para Nuvem via Symlink
agent: kairos
command: "*configure-cloud [--reset]"
version: 1
---

# Task: kairos-configure-cloud

## Propósito

Criar um symlink de `data/outputs/` para uma pasta local sincronizada por app de nuvem (Google Drive Desktop, OneDrive, Dropbox, iCloud), permitindo que outputs do Kairos apareçam automaticamente na nuvem compartilhada com o time. Zero OAuth — o sync é delegado inteiramente ao app oficial do provedor.

---

## Modos de Execução

### `*configure-cloud` — Configurar sync

**Passo 1 — Verificação do app de sync**

Perguntar amigavelmente:

```
Para sincronizar seus outputs com a nuvem, o Kairos cria um symlink de data/outputs/
para uma pasta local que o app de nuvem do seu provedor já sincroniza automaticamente.

Você tem algum destes apps instalados?
  • Google Drive Desktop   → cria a pasta "Google Drive" em ~/
  • OneDrive               → cria a pasta "OneDrive" em ~/
  • Dropbox                → cria a pasta "Dropbox" em ~/
  • iCloud Drive (macOS)   → ~/Library/Mobile Documents/com~apple~CloudDocs/

Se ainda não tem um app instalado, baixe e configure o do seu provedor antes de continuar.
Após instalar, compartilhe a pasta com o time dentro do app.

Você tem um app de sync instalado e a pasta compartilhada criada? (s/n)
```

Se resposta for `n`: encerrar com instrução de instalar o app e retornar quando pronto. HALT.

**Passo 2 — Caminho da pasta sincronizada**

Perguntar:

```
Qual é o caminho LOCAL da pasta sincronizada que deve receber os outputs?
(ex: ~/Google Drive/Meu Drive/Kairos Outputs, ~/Dropbox/Equipe/Kairos)
```

Expandir `~` para o home do usuário antes de usar.

**Passo 3 — Validar caminho**

1. Verificar que o diretório existe: `test -d "{caminho}"`
   → Se não existir: perguntar se deseja criá-lo. Se sim: `mkdir -p "{caminho}"`. Se não: HALT.
2. Verificar que é gravável: tentar escrever arquivo de teste temporário.
   → Se não gravável: informar o problema e HALT.

**Passo 4 — Provedor declarado**

Inferir provedor a partir do caminho (Google Drive, OneDrive, Dropbox, iCloud, outro).
Confirmar com o usuário:

```
Provedor detectado: {provedor}
Isso está correto? (s/n — se não, informe o nome do provedor)
```

**Passo 5 — Migração de conteúdo existente**

Verificar se `data/outputs/` existe como diretório (não symlink) com conteúdo:

```bash
[ -d "data/outputs" ] && [ ! -L "data/outputs" ] && [ "$(ls -A data/outputs 2>/dev/null)" ]
```

Se sim, perguntar:

```
data/outputs/ existe e tem conteúdo. Deseja mover esses arquivos para
{caminho} antes de criar o symlink? (s para mover / n para deixar apenas no destino)
```

- Se `s`: executar `mv data/outputs/* "{caminho}/"` (mover conteúdo, não a pasta)
- Se `n`: prosseguir sem mover

Remover o diretório `data/outputs` (agora vazio ou inexistente) para liberar o caminho:
`rm -rf data/outputs`

**Passo 6 — Criar symlink**

```bash
ln -s "{caminho}" data/outputs
```

**No Windows:** se o comando falhar com erro de permissão (`ln` via Git Bash ou WSL), exibir:

```
⚠️  Falha ao criar symlink no Windows.

Para criar symlinks no Windows você precisa de um dos seguintes:
  1. Developer Mode habilitado:
     Configurações → Privacidade e segurança → Para desenvolvedores → Ativar "Modo Desenvolvedor"
  2. Executar o terminal como Administrador e repetir o comando.

Sem symlink nativo, o sync de outputs não pode ser configurado por esta task.
Alternativa manual: mova data/outputs/ para a pasta de nuvem e referencie-a no
seu workflow — mas o Kairos não gerencia esse caminho automaticamente.
```

HALT sem fallback automático para variável de path.

**Passo 7 — Validar symlink**

Escrever arquivo de teste e verificar leitura:

```bash
echo "kairos-sync-test" > data/outputs/.sync-test && cat data/outputs/.sync-test && rm data/outputs/.sync-test
```

→ Se falhar: informar erro, remover symlink criado (`rm data/outputs`), restaurar diretório (`mkdir -p data/outputs`) e HALT.

**Passo 8 — Salvar configuração**

Criar/atualizar `.kairos-core/runtime/cloud-sync.json`:

```json
{
  "configured": true,
  "symlink_target": "{caminho expandido}",
  "provider": "{provedor}",
  "configured_at": "{ISO 8601}"
}
```

**Passo 9 — Reportar sucesso**

```
✅ Cloud sync configurado com sucesso!

  Symlink criado:  data/outputs/ → {caminho}
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
- No Windows, symlinks fora do Developer Mode exigem privilégio de administrador. A task não tenta workarounds (decisão arquitetural — ver AC da story 7.4).
- `.kairos-core/runtime/cloud-sync.json` é L4 (volátil, gitignored) — não entra no manifesto.
- O `*doctor` lê `cloud-sync.json` para validar integridade do symlink após configuração.
