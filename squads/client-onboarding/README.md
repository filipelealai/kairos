# Squad Client Onboarding — Do fechamento ao kickoff

## O que faz

Gerencia o ciclo pós-comercial completo: desde o momento em que um deal é fechado na call
até o início formal do projeto. O squad extrai contexto do cliente, gera proposta comercial,
contrato legal e kit de onboarding — tudo em documentos estruturados, prontos para revisão
e entrega.

O design é modular: cada agente é autossuficiente e pode ser usado isoladamente. O pipeline
completo garante consistência entre os documentos (o brief alimenta todos os demais).

## Agentes

| Agente | Persona | Responsabilidade | Comando |
|--------|---------|-----------------|---------|
| @brief-extractor | Brix | Extrai e estrutura contexto do material do cliente | `*extract` |
| @proposal-writer | Pró | Gera proposta comercial (pré-compromisso) | `*write` |
| @contract-writer | Jus | Gera contrato de prestação de serviços | `*draft` |
| @onboarding-writer | Ori | Gera kit de onboarding (pós-assinatura) | `*kit` |

## Pipeline

```
@brief-extractor *extract
        ↓
@proposal-writer *write {empresa}
        ↓
@contract-writer *draft {empresa}
        ↓
@onboarding-writer *kit {empresa}
```

Execução parcial: **permitida** — cada agente funciona de forma independente.

## Templates

Os templates ficam em `squads/client-onboarding/templates/` e são a base modular de cada documento.

```
templates/
  proposal/              — seções da proposta comercial
  contract/              — cláusulas padrão do contrato (base genérica)
  contract/variants/     — variantes por tipo de serviço (sobrepõem cláusulas específicas)
  onboarding/            — seções do kit de onboarding
```

### Quando usar qual variante de contrato

O @contract-writer seleciona a variante com base no tipo de serviço identificado no brief.
A descrição completa de cada tipo está em `squads/client-onboarding/data/kb.md#tipos-de-servico`.

| Tipo de serviço | Variante | Usar quando |
|----------------|----------|-------------|
| **Projeto Fechado** | `contract/variants/projeto-fechado/` | Escopo bem definido, entregáveis específicos, prazo com data de término, valor total acordado antes do início. Ex: desenvolvimento de landing page, consultoria pontual, criação de estratégia para período definido. |
| **Retainer Mensal** | `contract/variants/retainer-mensal/` | Prestação contínua, volume mensal acordado (horas ou escopo recorrente), cobrança fixa mensal, sem data de término. Ex: gestão de mídia social, suporte técnico mensal, consultoria recorrente. |
| **Hora Avulsa** | `contract/variants/hora-avulsa/` | Demanda variável e imprevisível, cobrança por hora efetivamente trabalhada, sem compromisso de volume. Ex: consultoria ad-hoc, suporte técnico avulso, sessões de mentoria. |

**Casos ambíguos:**
- Cliente quer "retainer" mas o escopo muda todo mês → provavelmente **Projeto Fechado** com renovação
- Cliente quer "suporte" mas com SLA e volume garantido → **Retainer Mensal**
- Em dúvida: usar as perguntas do @brief-extractor para identificar o tipo antes de gerar o contrato

**Princípio de sobreposição:** as variantes substituem apenas as cláusulas específicas (pagamento, vigência, rescisão e, quando aplicável, cláusulas extras). Cláusulas sem variante (partes, objeto, responsabilidades, confidencialidade, PI, foro) são sempre as genéricas de `contract/`.

## Fonte de Dados

Input manual: texto livre passado diretamente ao @brief-extractor (brief do cliente,
notas de call, documentos copiados, links de documentos).

## Outputs

| Agente | Output | Destino |
|--------|--------|---------|
| @brief-extractor | `data/outputs/client-onboarding/briefs/brief-extractor_brief-{empresa}-YYYY-MM-DD.md` | Base para todos os demais |
| @proposal-writer | `data/outputs/client-onboarding/proposals/proposal-writer_proposal-{empresa}-YYYY-MM-DD.md` | Revisão + envio ao cliente |
| @contract-writer | `data/outputs/client-onboarding/contracts/contract-writer_contract-{empresa}-YYYY-MM-DD.md` | Revisão jurídica + assinatura |
| @onboarding-writer | `data/outputs/client-onboarding/onboarding/onboarding-writer_kit-{empresa}-YYYY-MM-DD.md` | Entrega ao cliente no kickoff |

> Todos os outputs MD podem ser convertidos para PDF com `npx md-to-pdf {arquivo.md}` — gera `{arquivo.pdf}` no mesmo diretório. Ferramenta: md-to-pdf v11.6.2 (Puppeteer + Chromium embutido, sem dependências externas).

## Como Usar

**Pipeline completo (caso típico):**
```
@brief-extractor *extract
@proposal-writer *write {empresa}
@contract-writer *draft {empresa}
@onboarding-writer *kit {empresa}
```

**Só proposta (brief já existente):**
```
@proposal-writer *write {empresa}
```

**Só contrato (proposta aprovada externamente):**
```
@contract-writer *draft {empresa}
```

**Só kit de onboarding (contrato já assinado):**
```
@onboarding-writer *kit {empresa}
```
