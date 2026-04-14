# Constituição do Kairos

> Princípios não-negociáveis do framework. Nada aqui pode ser violado, contornado ou ignorado — por nenhum agente, em nenhum contexto.
> Mudanças exigem decisão arquitetural explícita e bump MAJOR de versão.

---

## I. Separação de Responsabilidades

**Kairos pensa. n8n age.**

1. Kairos **nunca envia e-mails diretamente** — qualquer disparo passa exclusivamente pelo n8n.
2. Kairos **nunca escreve na planilha do Google Sheets** — leitura via webhook é permitida, escrita nunca.
3. Kairos é **read-only** em relação a fontes externas — sem side effects no acesso a dados.
4. n8n é o único sistema com permissão de agir sobre destinatários reais.

## II. Controle de Versão e Push

5. **Somente `@kairos *push`** pode fazer `git push` — nenhum outro agente, nenhuma conversa principal.
6. Todo `git push` **deve ser precedido de `@kairos *pre-push` com resultado PASS** na mesma sessão.
7. **Toda mudança estrutural no Kairos** (novo agente, nova task, nova rule, novo squad) **gera bump de versão** e entrada no `CHANGELOG.md`.
8. Bumps de versão são **exclusivos do `@kairos *version`** — nunca editar `core-config.yaml` ou `CHANGELOG.md` manualmente para versionar.

## III. Autoridade dos Agentes

9. A **matriz de autoridade** em `.claude/rules/agent-authority.md` é vinculante — nenhum agente executa operação fora de seu escopo.
10. **`@kairos`** tem autoridade sobre todos os outros agentes, mas **não substitui** o trabalho operacional dos squads — governa, não executa.
11. Stories em `docs/stories/` rastreiam **desenvolvimento do framework Kairos** — outputs operacionais (emails, scores, relatórios) vão para `data/outputs/`.

## IV. Integridade dos Dados

12. Kairos **nunca inventa métricas, leads, scores ou e-mails** — dados gerados vêm sempre de fontes reais (webhook, scripts TS).
13. Outputs são **idempotentes por data** — regerar no mesmo dia sobrescreve; comportamento intencional.
14. Scripts TypeScript em `src/agents/` são a **única fonte de computação pura** — agentes de IA interpretam e orquestram, não recalculam manualmente.

## V. Evolução do Framework

15. Novas capacidades seguem o princípio **IDS: REUTILIZAR > ADAPTAR > CRIAR** (ver `.claude/rules/ids-principles.md`).
16. Mudanças nas camadas L1 e L2 (ver `.claude/rules/framework-layers.md`) **requerem justificativa explícita** e revisão de @kairos.
17. A constituição **não é editada** pelo executor — apenas @kairos pode propor mudanças, e apenas com bump MAJOR.

---

*Versão inicial criada em 2026-04-14.*
