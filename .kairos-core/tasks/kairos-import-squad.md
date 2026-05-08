---
kairos-owned: true
kairos-version: 3.15.0
id: kairos-import-squad
title: Importar Squad de Arquivo Distribuível
agent: kairos
command: "*import-squad"
version: 1
---

# Task: kairos-import-squad

## Propósito

Instalar um squad exportado via `*export-squad` em uma instância Kairos destino. Valida checksum e versão de framework, resolve conflitos com squads existentes, aplica vars de ambiente, registra imports no CLAUDE.md e valida dependências externas.

---

## Sintaxe

```
*import-squad {path-do-arquivo}
```

- `{path-do-arquivo}` — obrigatório. Path para o arquivo `.tar.gz` ou `.zip` gerado pelo `*export-squad`.

---

## Execução

### Passo 1 — Validação do arquivo

1. Verificar que o arquivo existe no path informado
   → Se não existir: HALT com "Arquivo não encontrado: {path}"
2. Extrair o arquivo em diretório temporário
3. Verificar que `export-manifest.yaml` existe na raiz do conteúdo extraído
   → Se não existir: HALT com "Arquivo inválido — export-manifest.yaml não encontrado. O arquivo foi gerado pelo *export-squad?"
4. Ler `export-manifest.yaml`

### Passo 2 — Validação de checksum

1. Recalcular SHA-256 usando **paths relativos** ao diretório de extração, excluindo `export-manifest.yaml`:
   ```bash
   cd {dir-extração} && find . -type f ! -name "export-manifest.yaml" | sort | xargs sha256sum | sha256sum | cut -d' ' -f1
   ```
2. Comparar com `checksum` declarado no manifesto
   → Se divergir: HALT com "Checksum inválido — o arquivo pode estar corrompido ou foi modificado após o export."

### Passo 3 — Validação de versão de framework

1. Ler versão atual do framework local em `.kairos-core/core-config.yaml` (campo `framework.version`)
2. Comparar com `framework_version_major` do `export-manifest.yaml`
3. **Se major divergir:**
   ```
   ⚠️  Atenção: versão major do framework diverge.
   
   Export gerado em: Kairos v{versão-export} (major: {N})
   Instância atual: Kairos v{versão-local} (major: {M})
   
   Squads podem depender de recursos introduzidos na versão {versão-export}.
   Importar em versão diferente pode causar comportamento inesperado.
   
   Prosseguir mesmo assim? (s/n)
   ```
   → Se usuário responder "n": HALT
   → Se responder "s": continuar com WARN registrado

### Passo 4 — Resolução de conflito com squad existente

1. Verificar se `squads/{nome}/squad.yaml` já existe na instância
2. **Se não existir:** prosseguir direto para o Passo 5 (instalação limpa)
3. **Se existir:** apresentar opções:

```
⚠️  Squad '{nome}' já existe nesta instância.

Como prosseguir?

  1. Atualizar (recomendado) — substitui apenas arquivos com conteúdo divergente,
     preservando customizações locais. Mostra diff resumido antes de aplicar.
  2. Sobrescrever — apaga o squad existente e reescreve com o do export.
     ⚠️  Operação destrutiva: customizações locais serão perdidas.
  3. Renomear — importa com novo nome (evita conflito).
  4. Cancelar

Escolha (1/2/3/4):
```

**Opção 1 — Atualizar:**
- Para cada arquivo no pacote, comparar conteúdo com o arquivo local correspondente
- Listar diferenças em formato resumido:
  ```
  Arquivos a atualizar ({N}):
    ~ squads/{nome}/agents/pre-call.yaml        (conteúdo diverge)
    ~ .claude/commands/kairos/agents/pre-call.md (conteúdo diverge)
    = squads/{nome}/squad.yaml                  (sem mudança)
  
  Arquivos novos ({N}):
    + .kairos-core/agents/pre-call/MEMORY.md    (não existe localmente)
  
  Aplicar? (s/n)
  ```
- Se usuário confirmar: copiar apenas arquivos divergentes e novos

**Opção 2 — Sobrescrever:**
- Pedir confirmação explícita: "Tem certeza? Digite 'sobrescrever' para confirmar:"
- Se confirmado: remover `squads/{nome}/` e reescrever com o do pacote

**Opção 3 — Renomear:**
- Perguntar: "Novo nome para o squad (slug em kebab-case): "
- Substituir todas as ocorrências do nome original no conteúdo copiado pelo novo nome
  → Ajustar: `squads/{novo-nome}/`, referências em tasks e personas (não modificar conteúdo interno das personas — apenas nomes de pasta)
- Prosseguir como instalação limpa com o novo nome

### Passo 5 — Instalação dos artefatos

Copiar arquivos do pacote para a instância:

1. `squads/{nome}/` → copiar inteiro para `squads/{nome}/`
2. Tasks (arquivos em `.kairos-core/tasks/` do pacote) → copiar para `.kairos-core/tasks/`
   → Se task de mesmo nome já existe: confirmar antes de sobrescrever
3. Personas (`.claude/commands/kairos/agents/{id}.md`) → copiar para `.claude/commands/kairos/agents/`
   → Se persona de mesmo nome já existe e diverge: avisar, perguntar antes de sobrescrever
4. Memórias (`.kairos-core/agents/{id}/MEMORY.md`):
   → Criar diretório `.kairos-core/agents/{id}/` se não existir
   → Se MEMORY.md já existe localmente: **não sobrescrever** (memória local tem precedência)
     Avisar: "MEMORY.md de {id} preservada (versão local mantida)"
   → Se não existe: copiar do pacote

### Passo 6 — Patch de vars de ambiente

1. Ler `squad-env-patch.env` do pacote
2. Verificar se `.env.example` existe na raiz da instância
   → Se não existir: criar arquivo vazio com aviso ao usuário
3. Verificar se bloco `# --- squad:{nome} - START ---` já existe no `.env.example`
   → Se já existe: ignorar (não duplicar), avisar "Bloco de vars do squad '{nome}' já presente em .env.example"
4. Aplicar patch **fora** de quaisquer seções `# KAIROS-MANAGED-START:` / `# KAIROS-MANAGED-END:` — sempre após a última linha não-managed do arquivo:
   ```
   
   # --- squad:{nome} - START ---
   # Vars de ambiente para o squad {nome}
   # Copie as variáveis relevantes para seu .env e preencha os valores
   
   {conteúdo do squad-env-patch.env}
   # --- squad:{nome} - END ---
   ```

### Passo 7 — Registrar squad em CLAUDE.md

1. Ler `CLAUDE.md` da instância
2. Localizar a seção user-owned "## Squads ativos" (fora de qualquer bloco `KAIROS-MANAGED-*`)
3. Verificar se imports do squad já existem (linhas com `@squads/{nome}/`)
   → Se já existem: pular este passo
4. Adicionar imports ao final da seção "Squads ativos":
   ```
   @squads/{nome}/rules/{nome}-lifecycle.md
   @squads/{nome}/rules/memory-imports.md
   @squads/{nome}/rules/agent-authority.md
   ```
   → Incluir apenas os arquivos de rules que existem no squad instalado

### Passo 8 — Validação de dependências externas

Para cada entrada em `external_dependencies` do `export-manifest.yaml`:

**Se `type: cli`:**
1. Tentar executar o comando de detecção:
   - Unix: executar `which {name}` ou o comando declarado em `detection.unix`
   - Windows: executar `Get-Command {name}` ou o comando declarado em `detection.windows`
2. **Se encontrado:** `✅ {name} — encontrado`
3. **Se não encontrado:**
   ```
   ⚠️  {name} não encontrado — necessário para {purpose}
   
   Instalação:
   {instruções de install.*  do manifest, formatadas por SO detectado}
   
   Instalar automaticamente via gerenciador de pacotes? (s/n)
   ```
   - Se usuário responder "s": executar o comando de install declarado (se houver `install.npm`, `install.linux`, `install.mac` ou `install.windows` para o SO atual)
     → Confirmar sucesso com uma re-detecção após install
     → Se instalar automaticamente: informar o comando que será executado **antes** de executar
   - Se responder "n" ou se não houver comando de install automático: registrar como WARN

**Se `type: service`:**
1. Exibir a nota informativa de detecção sem tentar instalação automática:
   ```
   ℹ️  {name} — serviço remoto. {note de detection}
   
   Para configurar: {instruções de install.description}
   ```

**Se `optional: true`:** prefixar output com `(opcional)` e não bloquear nem exibir como WARN

### Passo 9 — Health check final

Rodar `*doctor` ao final da importação.

### Passo 10 — Output final

```
✅ Squad '{nome}' importado com sucesso.

Artefatos instalados:
  📁 squads/{nome}/
  📄 {N} personas
  🧠 {N} memórias (preservadas se já existiam localmente)
  📋 {N} tasks
  🔧 .env.example atualizado (bloco squad:{nome})
  📝 CLAUDE.md atualizado (imports do squad)

Dependências externas:
  ✅ {nome-dep-ok}
  ⚠️  {nome-dep-warn} — instalar manualmente ({instrução})

Para ativar o squad: @{agente-principal-do-squad}
```

---

## Tratamento de Casos Especiais

**Arquivo corrompido ou não gerado pelo *export-squad:**
→ HALT no Passo 1 ou 2 com mensagem explicativa

**CLAUDE.md não tem seção "Squads ativos":**
→ WARN "Seção 'Squads ativos' não encontrada em CLAUDE.md. Adicione manualmente os imports do squad:{imports}"

**Squad importado referencia personas de outros squads:**
→ Avisar que personas de squads de dependência precisam estar instaladas separadamente

---

## Completion

Sem handoff. Import é operação pontual.

Após completar: rodar `*doctor` (Passo 9) e exibir resultado consolidado.
