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

## Notas

- Não há agent persona neste squad — as operações são executadas pelo @kairos
- Nunca fazer push direto para `origin main` sem passar pelo push-dual
- O push-dual usa `manifest.yaml` como fonte de verdade dos arquivos framework
