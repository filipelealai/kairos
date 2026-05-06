---
kairos-owned: true
kairos-version: 3.13.0
task: Kairos Push
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: deployment
elicit: false
Entrada: |
  - pre_push_passed: deve ser true na sessão atual (verificado antes de qualquer execução)
Saida: |
  - git push executado ao remoto
  - Confirmação com hash do commit e URL (se disponível)
Checklist:
  - "[ ] Verificar que pre_push_passed = true na sessão atual"
  - "[ ] Confirmar branch de destino com o usuário se não for main"
  - "[ ] Rodar git push"
  - "[ ] Confirmar resultado"
  - "[ ] Atualizar status de story ativa se aplicável"
---

# *push — Push ao Repositório Remoto

## Guard de Git

**ANTES de qualquer coisa**, verificar se o Git está disponível:

```bash
git --version
```

Se o comando falhar (Git não instalado ou não encontrado no PATH):

```
🚫 HALT — Git não encontrado.

O *push requer Git para operar. Instale com:
  • Linux (apt):   sudo apt install git
  • macOS (brew):  brew install git
  • Windows:       winget install --id Git.Git -e

Deseja que eu execute a instalação agora? (s/n):
```

Se `s` (ou `sim`): executar o comando de instalação correspondente ao SO detectado com confirmação explícita antes de rodar.
Se `n` (ou `não`): HALT — encerrar sem executar nada.

---

## Guard Obrigatório

**ANTES de qualquer coisa**, verifique o estado de sessão:

```
SE pre_push_passed != true na sessão atual:
  RECUSAR com:
  "🚫 Push recusado. *pre-push não foi executado ou retornou BLOCK nesta sessão.
   Execute *pre-push primeiro e certifique-se de que retorna PASS."
  HALT — não continuar
```

Se `*pre-push` foi rodado em outra sessão (não a atual), tratar como não executado.

## Execução

### Passo 1 — Confirmar branch

```bash
git branch --show-current
```

Se branch é `main`:
- Avisar: "Você está prestes a fazer push direto para `main`. Confirma? (s/n)"
- Aguardar confirmação antes de prosseguir

Se branch é outra: prosseguir sem confirmação adicional.

### Passo 2 — Executar push

```bash
git push origin {branch}
```

### Passo 3 — Resultado

**Se push bem-sucedido:**
```
✅ Push realizado com sucesso

Branch: {branch}
Remote: origin
Último commit: {hash} — {mensagem}

{URL do remote se disponível via git remote get-url origin}
```

**Se push falhou:**
```
❌ Push falhou

Erro: {stderr do git}

Possíveis causas:
- Remote divergiu — rode: git pull --rebase origin {branch}
- Sem permissão — verifique credenciais git
- Branch protegida — contate administrador do repo
```

### Passo 4 — Pós-push

Se havia story com status `In Progress` cujo gate está PASS:
- Informar: "Story {id} tem gate PASS. Deseja atualizar o status para Done? (s/n)"
- Se confirmado: atualizar o campo `**Status:**` no arquivo da story para `Done`
- Atualizar `docs/stories/README.md` correspondente

Resetar `pre_push_passed = false` em sessão (força novo *pre-push no próximo ciclo).

## Restrições

- **Nunca** usar `--force` ou `--force-with-lease` sem confirmação explícita do usuário
- **Nunca** fazer push de `main` sem confirmação explícita
- **Nunca** executar sem pre_push_passed = true na sessão atual
