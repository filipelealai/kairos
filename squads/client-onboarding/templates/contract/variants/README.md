# Variantes de Contrato por Tipo de Serviço

As variantes substituem (ou complementam) as cláusulas genéricas de `templates/contract/`
quando o tipo de serviço tem características contratuais específicas.

## Como usar

1. Identificar o tipo de serviço (ver `squads/client-onboarding/data/kb.md#tipos-de-servico`)
2. Selecionar a variante correspondente
3. Substituir as cláusulas genéricas pelas da variante (apenas as cláusulas que existem na variante)
4. Cláusulas sem variante (01, 02, 07, 08, 09, 10): usar as genéricas de `templates/contract/`

## Mapa de Variantes

| Tipo | Variante | Cláusulas especializadas |
|------|----------|--------------------------|
| Projeto fechado | `projeto-fechado/` | 03-escopo, 04-pagamento, 05-vigencia, 06-rescisao |
| Retainer mensal | `retainer-mensal/` | 04-pagamento, 05-vigencia, 06-rescisao, 11-horas-incluidas |
| Hora avulsa | `hora-avulsa/` | 04-pagamento, 05-vigencia, 06-rescisao, 11-aprovacao-horas |

## Princípio de Sobreposição

A base permanece estável — variantes são **aditivas e substitutivas**, nunca quebram os templates canônicos:

- Cláusulas com variante → usar a variante
- Cláusulas sem variante → usar a genérica de `templates/contract/`
- Novas cláusulas de variante (ex: `11-*`) → adicionar ao final do contrato, antes do foro

> Variantes nunca modificam as cláusulas genéricas de `templates/contract/`.
> Para criar nova variante: seguir o padrão de nomenclatura e registrar neste README.
