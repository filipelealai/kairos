# Epic 2 — Automação de Disparo

**Status:** In Progress
**Objetivo:** Fechar o ciclo de prospecção — o n8n lê o JSON gerado pelo Kairos e executa os disparos, atualizando a planilha automaticamente.

---

## Descrição

O Kairos gera os e-mails mas ainda não os conecta ao mecanismo de envio. Este epic cobre a ponte entre o output do `@email-writer` (`data/emails/emails-YYYY-MM-DD.json`) e o disparo real via n8n, incluindo atualização de status na planilha e tratamento de emails suspeitos.

---

## Critério de Conclusão

- [ ] Workflow n8n lê `data/emails/emails-YYYY-MM-DD.json` automaticamente
- [ ] E-mails disparados via Gmail/SMTP com assunto e corpo corretos
- [ ] `email_suspeito = true` → e-mail não enviado (skip silencioso ou log)
- [ ] `Status do Envio` atualizado para `ENVIADO` na planilha após cada envio
- [ ] Falhas de envio registradas (não silenciosas)
- [ ] Rate limiting configurado (≤ 200/hora)

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| [2.1](../stories/2.1.story.md) | Loop de Disparo — n8n Lê JSON e Dispara E-mails | Draft |

---

## Stories Candidatas (não criadas ainda)

- **2.2** — Relatório de Disparo: n8n envia sumário de envios do dia para Filipe (Slack/e-mail)
- **2.3** — Retry Automático: retentar envios que falharam após N horas

---

## Dependências

- Epic 1 concluído ✓ (webhook + agentes operacionais)
- Credencial Gmail no n8n (verificar se já existe)

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-06 | Epic criado — story 2.1 em Draft |
