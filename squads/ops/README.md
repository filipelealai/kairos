# Squad ops — Governança de Repositório

Squad responsável por manter os dois remotes do Kairos sincronizados:

| Remote | Repo | Conteúdo |
|--------|------|----------|
| `origin` | `filipelealweb/kairos` | Framework puro (branch `main`) |
| `private` | `filipelealweb/kairos-pessoal` | Instância completa (branch `filipe-instance`) |

## Arquitetura

```
LOCAL — um único repo git, dois branches, dois remotes

  branch filipe-instance  ←── trabalho diário (framework + instância)
         │
         └─ push-dual sincroniza
                ↓
  branch main  ←── apenas framework (limpa, sem dados de instância)
```

## Comandos disponíveis

| Comando | Descrição |
|---------|-----------|
| `@kairos *push` | Executa push-dual — sincroniza ambos os remotes |

## Tasks

- [tasks/push-dual.md](tasks/push-dual.md) — Lógica completa do push dual-remote

## Recuperação (novo computador ou perda do repo local)

O repo privado (`kairos-pessoal`) é a fonte de verdade completa da instância.
Para restaurar o ambiente do zero:

```bash
# 1. Clonar do repo privado (tem tudo: framework + instância)
git clone https://github.com/filipelealweb/kairos-pessoal.git kairos
cd kairos

# 2. Ajustar remotes para a convenção esperada
git remote rename origin private
git remote add origin https://github.com/filipelealweb/kairos.git

# 3. Checkout da branch de trabalho
git checkout filipe-instance

# 4. Dependências
npm install
```

> O repo público (`kairos`) tem apenas o framework — não use-o como ponto de recuperação.

## Notas

- Não há agent persona neste squad — as operações são executadas pelo @kairos
- Nunca fazer push direto para `origin main` sem passar pelo push-dual
- O push-dual usa `manifest.yaml` como fonte de verdade dos arquivos framework
- **Execute `@kairos *push` regularmente** — enquanto `kairos-pessoal` não tiver o estado atual, a recuperação estará incompleta
