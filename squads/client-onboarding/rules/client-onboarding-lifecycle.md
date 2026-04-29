# Client Onboarding Lifecycle — Fluxo do Pipeline

## Fluxo Principal

```
@brief-extractor *extract
        ↓
@proposal-writer *write {empresa}
        ↓
  (aprovação do cliente — fora do Kairos)
        ↓
@contract-writer *draft {empresa}
        ↓
  (assinatura — fora do Kairos)
        ↓
@onboarding-writer *kit {empresa}
```

## Fases e Responsáveis

| Fase | Agente | Comando | Output |
|------|--------|---------|--------|
| 1. Extração | @brief-extractor (Brix) | `*extract` | `data/outputs/client-onboarding/briefs/brief-extractor_brief-{empresa}-YYYY-MM-DD.md` |
| 2. Proposta | @proposal-writer (Pró) | `*write {empresa}` | `data/outputs/client-onboarding/proposals/proposal-writer_proposal-{empresa}-YYYY-MM-DD.md` |
| 3. Contrato | @contract-writer (Jus) | `*draft {empresa}` | `data/outputs/client-onboarding/contracts/contract-writer_contract-{empresa}-YYYY-MM-DD.md` |
| 4. Onboarding | @onboarding-writer (Ori) | `*kit {empresa}` | `data/outputs/client-onboarding/onboarding/onboarding-writer_kit-{empresa}-YYYY-MM-DD.md` |

## Handoff Chain

```
brief-extractor → proposal-writer   : handoff-brief-extractor-to-proposal-writer-{ts}.yaml
proposal-writer → contract-writer   : handoff-proposal-writer-to-contract-writer-{ts}.yaml
contract-writer → onboarding-writer : handoff-contract-writer-to-onboarding-writer-{ts}.yaml
```

## Execução Parcial (permitida)

Cada agente é autossuficiente. Exemplos válidos:

- **Só proposta:** `@proposal-writer *write {empresa}` (sem brief formal prévio)
- **Só contrato:** `@contract-writer *draft {empresa}` (proposta aprovada externamente)
- **Só onboarding:** `@onboarding-writer *kit {empresa}` (contrato já assinado)
- **Extração + proposta:** `@brief-extractor *extract` → `@proposal-writer *write`

## Pontos de Aprovação Humana

O pipeline tem dois pontos onde o Kairos PARA e o usuário age externamente:

1. **Aprovação da proposta** — cliente revisa e aprova a proposta antes do contrato ser gerado
2. **Assinatura do contrato** — ambas as partes assinam antes do kit de onboarding ser entregue

O Kairos não controla nem monitora esses pontos. Cabe ao usuário retomar o pipeline após cada aprovação.

## Conversão para PDF

Todos os outputs são Markdown. A conversão para PDF é feita via ferramenta externa
(a ser definida na story de implementação — ver `squad.yaml` campo `integrations.pdf`).

## Frequência Recomendada

Sob demanda — uma execução por deal fechado.
`*revise` pode ser usado quantas vezes necessário para atualizar documentos.
