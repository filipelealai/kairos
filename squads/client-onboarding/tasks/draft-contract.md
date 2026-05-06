---
task: Draft Contract
responsavel: "@contract-writer"
responsavel_type: agent
atomic_layer: generation
elicit: false
Entrada: |
  - proposta: path da proposta aprovada ou contexto colado — obrigatório
  - brief: path do brief estruturado — obrigatório
  - empresa: nome da empresa cliente — obrigatório
Saida: |
  - contrato: data/outputs/client-onboarding/contracts/contract-writer_contract-{empresa}-{INSTANCE}-YYYY-MM-DD.md
Checklist:
  - "[ ] Carregar proposta aprovada e brief estruturado"
  - "[ ] Carregar template de contrato de squads/client-onboarding/templates/contract/"
  - "[ ] Adaptar cláusulas ao escopo específico do projeto"
  - "[ ] Marcar com [REVISAR JURIDICAMENTE] cláusulas sensíveis"
  - "[ ] Verificar consistência com a proposta aprovada"
  - "[ ] Sinalizar explicitamente ao usuário que o output é um rascunho"
  - "[ ] Salvar contrato em data/outputs/client-onboarding/contracts/"
  - "[ ] Gerar handoff para onboarding-writer se aplicável"
---

# *draft — Geração de Rascunho de Contrato de Prestação de Serviços

⚠️ **O output desta task é sempre um RASCUNHO** — nunca declarar como "pronto para assinar" sem revisão humana e, preferencialmente, revisão jurídica.

## Protocolo de Uso dos Templates

Os templates em `squads/client-onboarding/templates/contract/` são a base obrigatória.
Cada arquivo é uma cláusula ou seção independente.

**Cláusulas canônicas e obrigatoriedade:**

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

---

## Passo 0 — Selecionar variante de contrato por tipo de serviço

<!-- kairos-custom: seleção de variante -->
> Esta seção é adicionada pela Story 4.4. O @contract-writer deve executar este passo
> **antes** de carregar os templates, para usar as cláusulas especializadas corretas.

### 0.1 Identificar o tipo de serviço

Ler o brief e a proposta aprovada para classificar o serviço em um dos três tipos:

| Tipo | Indicadores no brief/proposta |
|------|-------------------------------|
| **Projeto Fechado** | Escopo delimitado, entregáveis listados, data de término, valor total fixo |
| **Retainer Mensal** | Serviço contínuo, cobrança mensal, horas/mês ou escopo recorrente, sem fim definido |
| **Hora Avulsa** | Demanda variável, cobrança por hora trabalhada, sem volume garantido |

Se o tipo não for claro a partir do brief/proposta:
```
⚠️ HALT — Tipo de serviço não identificado.

Para selecionar a variante de contrato correta, preciso identificar o modelo comercial:
1. Projeto Fechado — escopo e valor fixos, com data de término
2. Retainer Mensal — cobrança mensal recorrente, vigência contínua
3. Hora Avulsa — cobrança por hora, volume variável

Qual é o modelo deste projeto com {empresa}?
```

### 0.2 Carregar a variante correta

Com base no tipo identificado:

**Projeto Fechado:**
- Substituir cláusulas: `03-escopo-entregaveis.md`, `04-pagamento.md`, `05-vigencia.md`, `06-rescisao.md`
- Fonte: `squads/client-onboarding/templates/contract/variants/projeto-fechado/`
- Cláusulas extras: nenhuma

**Retainer Mensal:**
- Substituir cláusulas: `04-pagamento.md`, `05-vigencia.md`, `06-rescisao.md`
- Fonte: `squads/client-onboarding/templates/contract/variants/retainer-mensal/`
- Cláusula extra: `11-horas-incluidas.md` — adicionar após Cláusula 2ª **se** o retainer for baseado em horas. Se for baseado em entregas fixas recorrentes, omitir.

**Hora Avulsa:**
- Substituir cláusulas: `04-pagamento.md`, `05-vigencia.md`, `06-rescisao.md`
- Fonte: `squads/client-onboarding/templates/contract/variants/hora-avulsa/`
- Cláusula extra: `11-aprovacao-horas.md` — adicionar após Cláusula 2ª

**Cláusulas sempre genéricas** (usar `squads/client-onboarding/templates/contract/` independente do tipo):
`01-partes.md`, `02-objeto.md`, `07-responsabilidades.md`, `08-confidencialidade.md`, `09-propriedade-intelectual.md`, `10-foro.md`

### 0.3 Confirmar ao usuário (opcional, se tipo for ambíguo)

Quando houver classificação com base em inferência (brief não é explícito sobre o modelo):
```
→ Classificado como: {tipo de serviço}
   Base: {trecho do brief ou proposta que suporta a classificação}
   Usando variante: templates/contract/variants/{variante}/

   Se preferir outra variante, informe antes de prosseguir.
```

---

## Passo 1 — Carregar contexto

1. **Carregar a proposta aprovada** — se houver handoff pendente de proposal-writer, usá-lo automaticamente.
   Se não: pedir ao usuário o path da proposta ou contexto.

2. **Carregar o brief** — necessário para campos de qualificação das partes e restrições.

3. **Verificar consistência mínima antes de redigir:**

   Se escopo do contrato divergir da proposta aprovada:
   ```
   ⚠️ HALT — Divergência detectada entre proposta e brief:
   
   {descrever divergência específica}
   
   O que usar como base para o contrato? Confirme antes de prosseguir.
   ```

4. **Ler os templates** de `squads/client-onboarding/templates/contract/`.

---

## Passo 2 — Gerar contrato cláusula a cláusula

### Cláusula 01 — Qualificação das Partes

```markdown
## CONTRATO DE PRESTAÇÃO DE SERVIÇOS

**Contratante:**
Razão Social: {empresa_cliente} [REVISAR JURIDICAMENTE — confirmar razão social]
CNPJ/CPF: [REVISAR JURIDICAMENTE — preencher]
Endereço: [REVISAR JURIDICAMENTE — preencher]
Representante: {contato_principal do brief}

**Contratada:**
Razão Social: [REVISAR JURIDICAMENTE — preencher com dados do prestador]
CNPJ/CPF: [REVISAR JURIDICAMENTE — preencher]
Endereço: [REVISAR JURIDICAMENTE — preencher]

As partes acima qualificadas celebram o presente Contrato de Prestação de Serviços,
mediante as cláusulas e condições seguintes.
```

### Cláusula 02 — Objeto

```markdown
## Cláusula 1ª — Do Objeto

A CONTRATADA se compromete a prestar os serviços de {escopo resumido em 1-2 frases},
conforme detalhado na Cláusula 2ª deste instrumento.
```

### Cláusula 03 — Escopo e Entregáveis

Transcrever entregáveis da proposta aprovada. Ser específico — não usar linguagem genérica.

```markdown
## Cláusula 2ª — Do Escopo e Entregáveis

### 2.1 Serviços incluídos

{lista numerada de entregáveis — transcrever da proposta aprovada}

### 2.2 Fora do escopo

{lista do que não está incluído | "Quaisquer serviços não listados no item 2.1"}

### 2.3 Aceite de entregáveis

Cada entregável será considerado aceito {N} dias úteis após a entrega, salvo manifestação
escrita do CONTRATANTE indicando ajustes específicos.
```

### Cláusula 04 — Pagamento

```markdown
## Cláusula 3ª — Da Remuneração

### 3.1 Valor total

O valor total dos serviços é de R$ {valor} [REVISAR JURIDICAMENTE — confirmar valor].

### 3.2 Forma de pagamento

{condições da proposta | [REVISAR JURIDICAMENTE — definir parcelamento]}

### 3.3 Atraso de pagamento

Em caso de atraso no pagamento, incidirão juros de mora de 1% ao mês e multa de 2%
sobre o valor em atraso. [REVISAR JURIDICAMENTE]
```

### Cláusula 05 — Vigência

```markdown
## Cláusula 4ª — Da Vigência

O presente contrato vigorará pelo prazo de {prazo do brief/proposta}, com início em
{data de início | a definir na assinatura} e término previsto em {data de término}.

O contrato poderá ser renovado por igual período mediante acordo escrito entre as partes.
```

### Cláusula 06 — Rescisão

```markdown
## Cláusula 5ª — Da Rescisão

### 5.1 Rescisão imotivada

Qualquer das partes poderá rescindir este contrato mediante aviso prévio de {N} dias.
Em caso de rescisão imotivada pelo CONTRATANTE, será devida multa equivalente a
{%} do valor total remanescente. [REVISAR JURIDICAMENTE]

### 5.2 Rescisão por inadimplemento

O inadimplemento de qualquer cláusula deste contrato faculta à parte prejudicada a
rescisão imediata, sem prejuízo das perdas e danos cabíveis.
```

### Cláusula 07 — Responsabilidades

```markdown
## Cláusula 6ª — Das Responsabilidades

### 6.1 Obrigações da CONTRATADA

- Executar os serviços conforme escopo definido na Cláusula 2ª
- Manter sigilo sobre informações confidenciais do CONTRATANTE
- Comunicar imediatamente qualquer impedimento que possa afetar os prazos

### 6.2 Obrigações do CONTRATANTE

- Fornecer, em tempo hábil, os acessos, materiais e informações necessários à execução
- Efetuar os pagamentos nas condições estabelecidas na Cláusula 3ª
- Nomear um interlocutor responsável pelo projeto
```

### Cláusula 08 — Confidencialidade (recomendado)

```markdown
## Cláusula 7ª — Da Confidencialidade

As partes comprometem-se a manter sigilo sobre todas as informações técnicas, comerciais
e estratégicas trocadas no âmbito deste contrato, pelo período de {N} anos após o término.
[REVISAR JURIDICAMENTE — ajustar prazo e escopo do sigilo]
```

### Cláusula 09 — Propriedade Intelectual (recomendado)

```markdown
## Cláusula 8ª — Da Propriedade Intelectual

Após a quitação integral dos valores, todos os entregáveis produzidos pela CONTRATADA
no âmbito deste contrato serão de propriedade exclusiva do CONTRATANTE.
[REVISAR JURIDICAMENTE — definir se cessão é total ou licença]
```

### Cláusula 10 — Foro

```markdown
## Cláusula 9ª — Do Foro

As partes elegem o Foro da Comarca de {cidade} — {estado} para dirimir quaisquer
controvérsias oriundas deste instrumento, renunciando a qualquer outro, por mais
privilegiado que seja. [REVISAR JURIDICAMENTE — confirmar foro]

---

E por estarem assim justas e contratadas, as partes assinam o presente instrumento
em 2 (duas) vias de igual teor e forma.

{Cidade}, {data de assinatura}.

___________________________          ___________________________
CONTRATANTE                          CONTRATADA
{nome completo}                      {nome completo}
CPF/CNPJ: _______________            CPF/CNPJ: _______________
```

---

## Passo 3 — Sinalizar rascunho e campos sensíveis

Após redigir todas as cláusulas:

1. **Verificar consistência com a proposta:**
   - Valor do contrato = valor da proposta aprovada
   - Escopo do contrato = entregáveis da proposta
   - Prazo do contrato = prazo da proposta

2. **Listar todos os `[REVISAR JURIDICAMENTE]`** e exibir resumo ao usuário:
   ```
   ⚠️ Este é um RASCUNHO — {N} campos requerem revisão antes de assinar:
   
   [REVISAR JURIDICAMENTE]:
   - Cláusula 1: qualificação das partes (CNPJ, endereços)
   - Cláusula 3: valor e condições de pagamento
   - Cláusula 5: percentual de multa por rescisão
   - Cláusula 9: foro de eleição
   
   Recomendação: revisar com assessoria jurídica antes de enviar ao cliente.
   ```

---

## Passo 4 — Salvar e gerar handoff

### Estrutura do documento final

```markdown
# Contrato de Prestação de Serviços — {Empresa}

> ⚠️ RASCUNHO — Não enviar ao cliente sem revisão humana.
> Campos marcados [REVISAR JURIDICAMENTE] precisam de revisão antes de assinar.

**Data de geração:** YYYY-MM-DD
**Elaborado por:** @contract-writer (Jus) — rascunho para revisão

---

{cláusulas 01 a 10}

---

*Rascunho gerado por @contract-writer — revisar [REVISAR JURIDICAMENTE] antes de assinar*
```

### Salvar o arquivo

```
data/outputs/client-onboarding/contracts/contract-writer_contract-{empresa}-{INSTANCE}-YYYY-MM-DD.md
```

### Gerar handoff (se pipeline continua)

```yaml
handoff:
  from_agent: contract-writer
  to_agent: onboarding-writer
  last_command: "*draft"
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    output_file: "data/outputs/client-onboarding/contracts/contract-writer_contract-{empresa}-{INSTANCE}-YYYY-MM-DD.md"
    empresa: "{empresa}"
    campos_revisar_juridicamente: {N}
    prazo_contrato: "{prazo}"
  next_action: "*kit {empresa}"
```

Salvar em `.kairos-core/runtime/handoffs/handoff-contract-writer-to-onboarding-writer-{timestamp}.yaml`.

### Confirmar ao usuário

```
✅ Rascunho de contrato salvo:
   data/outputs/client-onboarding/contracts/contract-writer_contract-{empresa}-{INSTANCE}-YYYY-MM-DD.md

⚠️ RASCUNHO — {N} campo(s) marcados [REVISAR JURIDICAMENTE].
   Revisar com assessoria jurídica antes de enviar ao cliente para assinatura.

Próximo passo (após assinatura do contrato): @onboarding-writer *kit {empresa}
```
