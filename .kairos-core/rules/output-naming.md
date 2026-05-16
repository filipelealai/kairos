---
kairos-owned: true
kairos-version: 3.12.2
---

# Output Naming — Padrão Canônico de Nomenclatura

**Camada:** L3 (Gerenciado)

Define o padrão único de nomes de arquivos gerados por agentes, incluindo identificação de instância (`KAIROS_INSTANCE_NAME`). O objetivo é permitir que múltiplos membros da mesma equipe rodem o mesmo agente no mesmo dia sobre os mesmos dados sem colidir nomes de arquivo — um requisito do Epic 7 (Kairos Colaborativo Local).

---

## Padrão Canônico

```
data/outputs/{squad}/{tipo}/{agent}_{tipo-curto}-{INSTANCE}-YYYY-MM-DD.{ext}
```

Onde:

| Token | Significado | Exemplo |
|-------|-------------|---------|
| `{squad}` | slug do squad (kebab-case) | `cold-prospecting` |
| `{tipo}` | subdiretório por categoria de saída | `reports`, `briefs`, `analyses`, `emails` |
| `{agent}` | id do agente que gerou o arquivo | `campaign-analyst` |
| `{tipo-curto}` | rótulo curto descritivo do conteúdo (pode incluir slug de entidade quando aplicável, ex: `brief-{empresa}`) | `campaign`, `brief-acme-servicos` |
| `{INSTANCE}` | valor de `KAIROS_INSTANCE_NAME` (slug em kebab-case) | `filipe`, `maria`, `default` |
| `YYYY-MM-DD` | data ISO do dia da geração | `2026-05-05` |
| `{ext}` | extensão do arquivo | `md`, `json`, `csv` |

Exemplos concretos:

```
data/outputs/cold-prospecting/reports/campaign-analyst_campaign-filipe-2026-05-05.md
data/outputs/sales-pipeline/briefs/pre-call_brief-acme-servicos-maria-2026-05-05.md
data/outputs/client-onboarding/proposals/proposal-writer_proposal-acme-default-2026-05-05.md
data/outputs/cold-prospecting/emails/email-writer_emails-filipe-2026-05-05.json
```

> O segmento `{INSTANCE}` aparece **sempre** entre o último componente descritivo e a data. Nada vai depois da data exceto a extensão.

---

## Como ler `KAIROS_INSTANCE_NAME`

Agentes (e tasks que materializam outputs) **devem** consultar `KAIROS_INSTANCE_NAME` ao montar o nome de qualquer arquivo de saída.

### Regras de leitura

1. **Origem única:** o valor vem de `process.env.KAIROS_INSTANCE_NAME` (Node) ou equivalente da stack (`os.environ.get(...)` em Python). É carregado de `.env` na raiz do repositório.
2. **Slug obrigatório:** o valor é tratado como kebab-case. Se vier com espaço, maiúscula ou caractere especial, normalizar localmente (lowercase, espaços → `-`, remover acentos) antes de inserir no nome.
3. **Sem tokens reservados:** o valor não pode ser igual a `YYYY` ou `YYYY-MM-DD`. Se for, tratar como ausente e aplicar fallback.

### Fallback determinístico

Se `KAIROS_INSTANCE_NAME` não está definida, é vazia, ou viola a regra acima:

1. Usar o valor literal **`default`** no segmento `{INSTANCE}`.
2. Emitir uma única vez por sessão um warning ao usuário no formato:

   ```
   ⚠️  KAIROS_INSTANCE_NAME não configurado — usando "default" no nome dos outputs.
       Para evitar colisões em equipe, defina em .env:  KAIROS_INSTANCE_NAME=seu-nome
   ```

3. Prosseguir normalmente — o fallback nunca bloqueia execução.

> O warning é informativo, não fatal. O `*doctor` reporta o mesmo cenário como WARN.

---

## Quem implementa o que

| Camada | Responsabilidade |
|--------|------------------|
| **Framework** (esta rule + templates + tasks de governança) | Define o padrão, injeta o pattern em scaffolds (`*new-squad`, `*new-agent`), valida em `*doctor` |
| **Squad** (lifecycle, README, workflows, tasks de squad) | Consome o padrão — cada referência a output em squad usa `{INSTANCE}` no lugar correto |
| **Agente em runtime** | Lê a env var, aplica fallback, monta o nome final, salva o arquivo |

Squads **não reimplementam** a leitura/fallback — toda a lógica está concentrada no momento da escrita do arquivo, seguindo este contrato. Em scripts (`src/agents/{id}.{ext}`), centralizar a resolução em um helper único quando houver mais de um agente que escreve outputs.

---

## Casos especiais

### Outputs com slug de entidade no nome

Quando o nome incorpora uma entidade (ex: `{empresa}`, `{lead}`), o slug da entidade entra antes de `{INSTANCE}`:

```
{agent}_{tipo-curto}-{slug-entidade}-{INSTANCE}-YYYY-MM-DD.{ext}
```

Exemplo: `pre-call_brief-acme-servicos-filipe-2026-05-05.md`

### Outputs múltiplos no mesmo dia / instância

Se o mesmo agente gerar múltiplos arquivos no mesmo dia para a mesma entidade (ex: revisões), acrescentar sufixo `-vN` **após** a data — não antes do `{INSTANCE}`:

```
proposal-writer_proposal-acme-filipe-2026-05-05-v2.md
```

### Handoffs e logs internos

Arquivos em `.kairos-core/runtime/` (handoffs, logs) **não** seguem este padrão — são internos do framework, descartáveis e não-colidentes por timestamp embutido.

---

## Verificação

- `*doctor` valida se `KAIROS_INSTANCE_NAME` está configurada e emite WARN se ausente.
- Smoke manual: rodar qualquer agente operacional com a var setada e conferir o nome do arquivo gerado.

---

## Referências

- `.env.example` — entrada `KAIROS_INSTANCE_NAME` na seção `framework`
- `.kairos-core/templates/squad-template/agents/agent-id.yaml` — campo `outputs` usa o padrão
- `.kairos-core/tasks/kairos-new-squad.md` — injeta o pattern em scaffolds
- `.kairos-core/tasks/kairos-doctor.md` — check 11 (INSTANCE_NAME configurado)
- Epic 7 — `docs/epics/epic-7-kairos-colaborativo-local.md`
