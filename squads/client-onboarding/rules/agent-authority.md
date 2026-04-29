# client-onboarding — Matriz de Autoridade

Matriz de autoridade dos agentes do squad client-onboarding. Autoridade do @kairos e regras universais vivem em `.claude/rules/agent-authority.md`.

---

## @brief-extractor (Brix) — Extração Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Extrair e estruturar context de material do cliente (`*extract`) | EXCLUSIVA |
| Revisar brief existente e identificar lacunas (`*review`) | EXCLUSIVA |
| Elicitar informações faltantes do usuário | AUTORIZADO |
| Gerar proposta, contrato ou onboarding | BLOQUEADA |
| Modificar dados do cliente fora do brief | BLOQUEADA |

---

## @proposal-writer (Pró) — Geração de Proposta Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Gerar proposta comercial (`*write`) | EXCLUSIVA |
| Revisar proposta existente (`*revise`) | EXCLUSIVA |
| Usar templates de `squads/client-onboarding/templates/proposal/` | AUTORIZADO |
| Gerar contrato ou onboarding | BLOQUEADA |
| Enviar proposta ao cliente diretamente | BLOQUEADA |

---

## @contract-writer (Jus) — Redação de Contrato Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Gerar rascunho de contrato (`*draft`) | EXCLUSIVA |
| Revisar contrato existente (`*revise`) | EXCLUSIVA |
| Usar templates de `squads/client-onboarding/templates/contract/` | AUTORIZADO |
| Assinar contratos ou declarar versão final | BLOQUEADA |
| Gerar onboarding | BLOQUEADA |
| Enviar contrato ao cliente diretamente | BLOQUEADA |

---

## @onboarding-writer (Ori) — Kit de Onboarding Exclusivo

| Operação | Autoridade |
|----------|-----------|
| Gerar kit de onboarding (`*kit`) | EXCLUSIVA |
| Revisar kit existente (`*revise`) | EXCLUSIVA |
| Usar templates de `squads/client-onboarding/templates/onboarding/` | AUTORIZADO |
| Enviar kit ao cliente diretamente | BLOQUEADA |
| Modificar contrato ou proposta | BLOQUEADA |

---

## Operações Universalmente Proibidas no Squad

- Enviar documentos ao cliente diretamente (sempre requer revisão manual do usuário)
- Assinar contratos ou declarar versão final de qualquer documento
- Modificar dados do cliente em sistemas externos
- Declarar um rascunho como "pronto para assinar" sem sinalização explícita de [REVISAR]

---

## Escalação Específica do Squad

| Situação | Ação |
|----------|------|
| Material do cliente insuficiente para gerar brief | HALT @brief-extractor — elicitar do usuário |
| Brief sem escopo mínimo para proposta | HALT @proposal-writer — consultar usuário |
| Proposta e brief divergem no escopo | HALT @contract-writer — consultar usuário antes de redigir |
| Escopo do projeto não identificável para kit | HALT @onboarding-writer — consultar usuário |
| Campos legais críticos ausentes no contrato | HALT @contract-writer — marcar [REVISAR JURIDICAMENTE] e alertar usuário |
