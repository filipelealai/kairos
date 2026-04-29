# Knowledge Base — client-onboarding

> Conhecimento específico do squad client-onboarding: decisões de ambiente, gotchas, convenções locais.
> Conteúdo de framework (aplica-se a qualquer instância) vive em `.kairos-core/data/kairos-kb.md`.

---

## Índice

- [Tipos de Serviço](#tipos-de-servico)
- [Decisões de Ambiente](#decisoes-de-ambiente)
- [Gotchas do Squad](#gotchas-do-squad)

---

## Decisões de Ambiente

### Conversão Markdown → PDF

**Decisão:** Usar `npx md-to-pdf` como ferramenta de conversão de documentos gerados pelo squad.

**Motivo:** Ambiente WSL2 desta instância não tem pandoc nem Chrome/Chromium instalados. `md-to-pdf` v11.6.2 está disponível via `npx` sem instalação adicional. Usa Puppeteer com Chromium embutido — funciona em WSL2.

**Comando de conversão:**
```bash
npx md-to-pdf {arquivo.md}
# Gera {arquivo.pdf} no mesmo diretório
```

**Limitações conhecidas:**
- Primeira execução pode ser lenta (download do Chromium embutido)
- CSS customizado: criar arquivo `.md-to-pdf.config.js` na raiz se precisar estilização
- Em WSL2: se o Chromium embutido falhar, passar `--chromium-path $(which chromium-browser)` se instalado manualmente depois

**Onde aplicar:** todos os outputs MD de `data/outputs/client-onboarding/` — propostas, contratos e kits de onboarding.

**Registrado em:** Story 4.3 (2026-04-28)

---

## Tipos de Serviço

Os serviços prestados se enquadram em três modalidades com características contratuais distintas.
Esta seção serve de base para a seleção de variantes de contrato pelo @contract-writer.

---

### Projeto Fechado

**Quando usar:** escopo bem definido, entregáveis específicos, prazo com data de término.

**Características:**
- Valor total fixo, acordado antes do início
- Pagamento por marco ou por entregável (ex: 50% na assinatura, 50% na entrega)
- Prazo determinado com data de início e término
- Mudanças de escopo requerem aditivo contratual com novo valor

**Exemplos de projeto:** desenvolvimento de landing page, consultoria pontual, auditoria de sistema, criação de estratégia de conteúdo para período definido.

**Variante de contrato:** `templates/contract/variants/projeto-fechado/`

---

### Retainer Mensal

**Quando usar:** prestação de serviços contínua, volume mensal acordado (horas ou escopo recorrente), sem data de término definida.

**Características:**
- Cobrança mensal fixa (subscription)
- Volume de horas ou entregas recorrentes incluídas por mês
- Vigência por prazo inicial (ex: 3 meses) com renovação automática
- Cancelamento com aviso prévio de 30 dias

**Exemplos de serviço:** gerenciamento de mídia social, suporte técnico mensal, consultoria recorrente, gestão de tráfego.

**Variante de contrato:** `templates/contract/variants/retainer-mensal/`

---

### Hora Avulsa

**Quando usar:** demanda variável e imprevisível, cobrança por hora efetivamente trabalhada, sem escopo fixo por sessão.

**Características:**
- Tarifa por hora definida em contrato
- Faturamento mensal com base em timesheet aprovado pelo cliente
- Sem compromisso de volume mínimo mensal
- Vigência aberta — qualquer parte pode cancelar com aviso curto

**Exemplos de serviço:** consultoria ad-hoc, suporte técnico avulso, sessões de mentoria, revisão pontual sob demanda.

**Variante de contrato:** `templates/contract/variants/hora-avulsa/`

---

## Gotchas do Squad

*(a preencher conforme o squad for operando)*

---

*Última atualização: 2026-04-28*
