---
kairos-owned: true
kairos-version: 4.4.0
---

# Instalação e Desinstalação do Kairos

Guia completo de instalação, configuração de cloud sync e desinstalação do Kairos Framework.

---

## Pré-requisitos

### Obrigatório

| Requisito | Onde obter |
|-----------|-----------|
| **Claude Code** (CLI ou aba "Claude Code" do Claude Desktop) | https://claude.ai/download |

O Kairos é construído sobre o Claude Code — sem ele, nenhum agente pode ser ativado.

### Opcional

| Requisito | Para que serve |
|-----------|---------------|
| **Git** | Contribuir com o framework, fazer push para repo privado, usar `*push` e `*pre-push` |
| **Node.js** | Se instalar o Claude Code CLI via npm |
| **App de nuvem** (Google Drive Desktop, OneDrive, Dropbox) | Sync de outputs com o time via `*configure-cloud` |

> **Nota sobre Git:** o Kairos funciona completamente sem Git para uso normal. Instalação, atualização (`*update`) e trabalho operacional não requerem Git. Apenas contribuidores do framework precisam de Git.

---

## Instalação

### Linux / macOS / WSL2

Execute o instalador via curl (sem precisar de Git):

```bash
curl -fsSL https://raw.githubusercontent.com/filipelealai/kairos/main/install.sh | bash
```

Ou baixe e execute manualmente:

```bash
curl -fsSL -o install-kairos.sh https://raw.githubusercontent.com/filipelealai/kairos/main/install.sh
bash install-kairos.sh
```

O instalador vai:
1. Verificar se o Claude Code está instalado
2. Perguntar onde instalar (default: `~/kairos`)
3. Baixar a versão mais recente do GitHub (sem `git clone`)
4. Pedir seu nome de instância (para identificar seus outputs)
5. Gerar o `.env` com `KAIROS_INSTANCE_NAME` configurado
6. Oferecer configuração de cloud sync (opcional)
7. Exibir instruções de como abrir

### Windows (nativo, sem WSL)

1. Abra o **PowerShell** (não CMD — use PowerShell 5.1+)

2. Execute:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/filipelealai/kairos/main/install.ps1" -OutFile "$env:TEMP\install-kairos.ps1"
& "$env:TEMP\install-kairos.ps1"
```

Ou baixe `install.ps1` manualmente do GitHub e execute:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

> **WSL2 detectado automaticamente:** se o instalador Windows detectar o WSL2, ele oferecerá redirecionar para o `install.sh` dentro do WSL2 — recomendado para melhor compatibilidade com o Claude Code CLI.

---

## Como abrir o Kairos após instalar

### Via terminal (Linux / macOS / WSL)

```bash
cd ~/kairos && claude
```

### Via Claude Desktop

1. Abra o app Claude Desktop
2. Clique na aba **Claude Code**
3. Clique em **Abrir projeto**
4. Selecione a pasta onde instalou o Kairos (ex: `~/kairos`)

### Primeiros passos após abrir

```
@kairos *status      → ver estado do sistema e versão
@kairos *help        → todos os comandos disponíveis
@kairos *chat        → conversar / planejar sem disparar comandos
@kairos *new-squad   → criar seu primeiro squad
```

---

## Cloud Sync de Outputs com o Time

O Kairos pode sincronizar os outputs gerados pelos agentes (relatórios, emails, análises) para uma pasta compartilhada com o time via Google Drive Desktop, OneDrive ou Dropbox. Zero OAuth — o sync é delegado ao app do seu provedor.

### Pré-requisitos

Antes de configurar, instale o app do seu provedor de nuvem:

| Provedor | App | Pasta criada |
|----------|-----|-------------|
| Google Drive Desktop | https://drive.google.com/drive/download | `~/Google Drive/` |
| OneDrive | Incluído no Windows; https://onedrive.live.com/download para Mac/Linux | `~/OneDrive/` |
| Dropbox | https://www.dropbox.com/install | `~/Dropbox/` |
| iCloud Drive | Automático no macOS | `~/Library/Mobile Documents/com~apple~CloudDocs/` |

Crie (ou identifique) a pasta compartilhada com o time dentro do provedor antes de continuar.

### Configurar no Kairos

Com o Claude Code aberto no projeto Kairos:

```
@kairos *configure-cloud
```

O comando vai guiar você pelo processo:
1. Confirmar que o app de nuvem está instalado
2. Pedir o caminho local da pasta sincronizada (ex: `~/Google Drive/Equipe/Kairos Outputs`)
3. Criar o symlink `data/outputs/ → {pasta de nuvem}`
4. Validar que o symlink funciona

Após configurar, todos os outputs dos agentes aparecem automaticamente na pasta compartilhada.

### Symlinks no Windows

No Windows, criar symlinks requer uma das seguintes opções:
- **Developer Mode habilitado** (recomendado): Configurações → Privacidade e segurança → Para desenvolvedores → Ativar "Modo Desenvolvedor"
- **Executar como Administrador**: abrir o PowerShell como Admin e executar `@kairos *configure-cloud`

Se a criação do symlink falhar, `*configure-cloud` exibirá as instruções específicas.

### Desfazer o sync

```
@kairos *configure-cloud --reset
```

O conteúdo na pasta de nuvem não é afetado — apenas o symlink é removido e `data/outputs/` volta a ser uma pasta local.

---

## Compartilhando Squads com o Time

Squads completos (com agentes, tarefas, memórias e dependências externas) podem ser exportados como arquivo único e importados em qualquer instância:

### Exportar um squad

```
@kairos *export-squad {nome-do-squad}
```

Gera `kairos-squad-{nome}-{versão}.tar.gz` pronto para ser enviado por e-mail, Drive, pendrive ou qualquer canal.

### Importar um squad

```
@kairos *import-squad {caminho/do/arquivo.tar.gz}
```

O importador:
- Valida o checksum e a versão do framework de origem
- Oferece opções se o squad já existe (atualizar / sobrescrever / renomear)
- Copia todas as dependências (personas, tarefas, memórias)
- Valida se as dependências externas (CLIs, serviços) estão disponíveis
- Roda `*doctor` ao final para confirmar integridade

---

## Atualizar o Kairos

Sem precisar de Git:

```
@kairos *update
```

O updater:
- Compara a versão local com a última tag publicada no GitHub
- Baixa o tarball da nova versão
- Atualiza apenas arquivos do framework (declarados no manifesto)
- Preserva todo o conteúdo user-owned (squads, scripts, .env, memórias)
- Roda `*doctor` ao final

O **SessionStart hook** verifica automaticamente se há versão nova disponível cada vez que você abre o Claude Code no projeto Kairos. Se houver, exibe um aviso sugerindo `*update`.

---

## Desinstalação

### Linux / macOS / WSL

Execute de dentro da pasta de instalação:

```bash
cd ~/kairos
bash uninstall.sh
```

O desinstalador pergunta:
- Preservar `data/outputs/`? (default: sim)
- Preservar `.env`? (default: sim)
- Apagar TUDO da pasta? (default: não — requer confirmação explícita)

### Windows (nativo)

```powershell
cd ~\kairos
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\uninstall.ps1
```

### O que é removido

- Todos os arquivos listados em `.kairos-core/manifest.yaml` como `owned_files`
- Seções `<!-- KAIROS-MANAGED-START/END -->` de arquivos mistos (`owned_sections`)
- Pastas vazias restantes (bottom-up)

### O que é preservado (por padrão)

- `data/outputs/` — seus outputs gerados
- `.env` — suas variáveis de ambiente
- `squads/` — seus squads e memórias
- `src/` — seus scripts e ferramentas
- `docs/` — seus epics e stories
- Todo conteúdo user-owned

---

## Troubleshooting

### Claude Code não encontrado

**Sintoma:** instalador aborta com "Claude Code não encontrado"

**Solução:**
1. Instale o Claude Desktop em https://claude.ai/download
2. Abra o app e ative a aba "Claude Code"
3. Ou instale o CLI: `npm install -g @anthropic-ai/claude-code`
4. Reabra o terminal e execute o instalador novamente

### Falha ao criar symlink no Windows

**Sintoma:** `*configure-cloud` falha com erro de permissão

**Soluções:**
1. Habilite o Developer Mode: Configurações → Para desenvolvedores → Modo Desenvolvedor
2. Ou execute o PowerShell como Administrador

### Versão não encontrada (download falha)

**Sintoma:** "Não foi possível obter a versão mais recente"

**Causas e soluções:**
- Sem internet: verifique a conexão
- Rate limit do GitHub: aguarde alguns minutos
- Proxy corporativo: configure as variáveis `http_proxy`/`https_proxy`
- Baixe manualmente em https://github.com/filipelealai/kairos/releases

### *doctor reporta arquivos ausentes após update

**Sintoma:** `@kairos *doctor` reporta FAIL em arquivos do manifesto

**Solução:** execute `@kairos *update` novamente — se o problema persistir, reinstale.

### SessionStart hook não aparece

**Sintoma:** nenhum aviso de versão nova ao abrir o Claude Code

**Verificar:**
1. O hook existe em `.claude/hooks/kairos-version-check.cjs`?
2. Está registrado em `.claude/settings.json` (chave `hooks`)?
3. Execute `@kairos *doctor` para diagnóstico completo

---

## Referências

- [`*update`](../../.kairos-core/tasks/kairos-update.md) — atualizar o framework
- [`*configure-cloud`](../../.kairos-core/tasks/kairos-configure-cloud.md) — configurar sync de outputs
- [`*export-squad`](../../.kairos-core/tasks/kairos-export-squad.md) — exportar squad para arquivo
- [`*import-squad`](../../.kairos-core/tasks/kairos-import-squad.md) — importar squad de arquivo
- [`*doctor`](../../.kairos-core/tasks/kairos-doctor.md) — health check do framework
- [output-naming.md](../../.kairos-core/rules/output-naming.md) — padrão de nomenclatura de outputs
- [ownership.md](../../.kairos-core/rules/ownership.md) — fronteira framework/usuário
