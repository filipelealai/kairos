# Pipeline Completo — Client Onboarding

## Fluxo

```
@brief-extractor *extract
        ↓ brief estruturado
@proposal-writer *write {empresa}
        ↓ proposta aprovada
@contract-writer *draft {empresa}
        ↓ contrato assinado
@onboarding-writer *kit {empresa}
        ↓ kit entregue ao cliente
```

## Fases

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

Diretório: `.kairos-core/runtime/handoffs/`

## Execução Parcial (permitida)

Exemplos de execuções válidas sem pipeline completo:

- **Só extração:** `@brief-extractor *extract` — organizar contexto do cliente sem gerar documentos
- **Só proposta:** `@proposal-writer *write {empresa}` — cliente já tem brief em outro formato
- **Só contrato:** `@contract-writer *draft {empresa}` — proposta aprovada externamente
- **Só onboarding:** `@onboarding-writer *kit {empresa}` — contrato já assinado, só falta kit
- **Proposta + contrato:** `@proposal-writer *write` → `@contract-writer *draft` — sem brief formal

## Frequência Recomendada

Sob demanda — executado uma vez por deal fechado.
Cada agente pode ser reexecutado isoladamente com `*revise` para atualizar o documento.
