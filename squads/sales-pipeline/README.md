# Squad Sales Pipeline — Prospecção à Venda

Squad que cobre o funil após a resposta do e-mail de prospecção: prepara contexto antes de calls e transforma transcrições em pipeline atualizado e follow-up pronto para envio.

## O que faz

O @pre-call (Rex) agrega dados do lead — planilha de prospecção, resposta do e-mail, formulários — e gera um brief curto com perguntas de descoberta calibradas para aquele lead específico.

O @call-analyst (Cal) processa a transcrição da call (Fathom ou similar), extrai sinais comerciais estruturados, determina o estágio do deal, atualiza o card no Trello e gera um rascunho de follow-up para revisão antes do envio. Deals com "não agora" são classificados como nurture — não como perdidos.

## Agentes

| Agente | Persona | Responsabilidade | Comando |
|--------|---------|-----------------|---------|
| @pre-call | Rex (Pesquisador) | Gerar brief pré-call agregando contexto do lead | `*brief` |
| @call-analyst | Cal (Analista) | Analisar transcrição, atualizar Trello, gerar follow-up | `*analyze` |

## Pipeline

```
@pre-call *brief {lead}
        ↓
  (call acontece)
        ↓
@call-analyst *analyze {transcrição}
```

Execução parcial: permitida — cada agente roda independentemente.

## Fonte de Dados

- **@pre-call**: Google Sheets do cold-prospecting (via webhook `https://n8n.vendoteca.com/webhook/kairos-leads`) + resposta do e-mail + formulários (futuro)
- **@call-analyst**: transcrição exportada do Fathom (input manual ou arquivo)

## Outputs

| Agente | Output | Destino |
|--------|--------|---------|
| @pre-call | `data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-YYYY-MM-DD.md` | Lido pelo usuário antes da call |
| @call-analyst | `data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-YYYY-MM-DD.md` | Arquivo + Trello + follow-up draft |

## Como Usar

```
# Antes da call
@pre-call *brief {nome do lead ou row_number}

# Após a call
@call-analyst *analyze {transcrição}

# Só follow-up (call já analisada)
@call-analyst *followup {empresa}
```

## Estágios do Pipeline (Trello)

`Interesse → Proposta → Negociação → Fechado`
`Nurture` (não agora — recontato futuro)
`Perdido`
