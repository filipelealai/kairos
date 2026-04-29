# Templates de Proposta

Cada arquivo neste diretório é um módulo independente de seção de proposta.
O @proposal-writer combina e adapta estas seções ao contexto de cada cliente.

## Seções Canônicas (a implementar na story)

| Arquivo | Seção | Obrigatório |
|---------|-------|-------------|
| `01-apresentacao.md` | Apresentação e contexto do cliente | Sim |
| `02-escopo.md` | Escopo do projeto e entregáveis | Sim |
| `03-metodologia.md` | Abordagem e metodologia de trabalho | Recomendado |
| `04-investimento.md` | Valores, forma de pagamento e condições | Sim |
| `05-prazo.md` | Cronograma e marcos principais | Sim |
| `06-proximos-passos.md` | O que acontece após aprovação | Sim |
| `07-sobre-nos.md` | Apresentação da empresa/profissional | Opcional |

## Como Adicionar Variantes

Para criar variante por tipo de serviço (ex: proposta para consultoria vs. desenvolvimento):
- Criar subdiretório `proposal/consultoria/` ou `proposal/desenvolvimento/`
- Copiar seções relevantes e adaptar

A base estável permanece em `proposal/` — variantes vivem em subdiretórios.
