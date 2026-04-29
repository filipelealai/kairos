# Templates de Contrato

Cada arquivo neste diretório é um módulo de cláusula ou seção de contrato.
O @contract-writer seleciona e adapta as cláusulas ao escopo de cada projeto.

## Cláusulas Canônicas (a implementar na story)

| Arquivo | Cláusula | Obrigatório |
|---------|---------|-------------|
| `01-partes.md` | Qualificação das partes contratantes | Sim |
| `02-objeto.md` | Objeto do contrato | Sim |
| `03-escopo-entregaveis.md` | Escopo detalhado e entregáveis | Sim |
| `04-pagamento.md` | Valores, forma e condições de pagamento | Sim |
| `05-vigencia.md` | Vigência e prazo do contrato | Sim |
| `06-rescisao.md` | Condições de rescisão e multas | Sim |
| `07-responsabilidades.md` | Obrigações de cada parte | Sim |
| `08-confidencialidade.md` | Cláusula de sigilo | Recomendado |
| `09-propriedade-intelectual.md` | Titularidade dos entregáveis | Recomendado |
| `10-foro.md` | Foro de eleição | Sim |

## Campos Padrão para Preencher

Todos os contratos gerados devem ter estes campos preenchidos ou marcados [REVISAR JURIDICAMENTE]:
- Nome completo / razão social das partes
- CPF/CNPJ
- Endereço
- Valor e condições de pagamento
- Data de início e término
- Foro

## Como Adicionar Cláusulas Específicas

Para adicionar cláusula específica por tipo de serviço (ex: SLA para software):
- Criar arquivo com prefixo numérico após as canônicas: `11-sla.md`
- Documentar quando usar: adicionar linha na tabela acima

A base permanece estável — novas cláusulas são aditivas, nunca substituem as canônicas.
