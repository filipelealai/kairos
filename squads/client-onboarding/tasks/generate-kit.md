---
task: Generate Onboarding Kit
responsavel: "@onboarding-writer"
responsavel_type: agent
atomic_layer: generation
elicit: false
Entrada: |
  - brief: path do brief estruturado — obrigatório
  - empresa: nome da empresa cliente — obrigatório
  - contrato: path do contrato (para referência de escopo e prazo) — opcional
Saida: |
  - kit: data/outputs/client-onboarding/onboarding/onboarding-writer_kit-{empresa}-{INSTANCE}-YYYY-MM-DD.md
Checklist:
  - "[ ] Carregar brief estruturado e contexto do projeto"
  - "[ ] Carregar template de onboarding de squads/client-onboarding/templates/onboarding/"
  - "[ ] Gerar seção: boas-vindas personalizada"
  - "[ ] Gerar seção: próximos passos (o que o cliente deve fazer agora)"
  - "[ ] Gerar seção: acessos e informações necessárias (o que o cliente deve nos enviar)"
  - "[ ] Gerar seção: cronograma inicial"
  - "[ ] Gerar seção: contatos e canais de comunicação"
  - "[ ] Personalizar ao tipo de projeto e perfil do cliente"
  - "[ ] Salvar kit em data/outputs/client-onboarding/onboarding/"
---

# *kit — Geração do Kit de Onboarding

## Protocolo de Personalização por Tipo de Projeto

O kit de onboarding é adaptado ao **tipo de projeto** detectado no brief. Perfis canônicos:

| Tipo | Características | O que personalizar |
|------|-----------------|-------------------|
| **Desenvolvimento** | Entregas técnicas, sprints, ambiente de staging | Acessos técnicos, repositório, deploy |
| **Consultoria** | Workshops, diagnósticos, recomendações | Agenda de sessões, materiais analíticos |
| **Conteúdo/Marketing** | Calendário editorial, aprovações criativas | Guia de marca, canais de aprovação |
| **Automação/Integrações** | APIs, workflows, dados | Credenciais de sistemas, documentação técnica |
| **Genérico** | Qualquer projeto não categorizado | Seções padrão sem especialização |

Detectar o tipo a partir do `escopo_esperado` e `stack_atual` do brief.

---

## Passo 1 — Carregar contexto

1. **Carregar o brief** — se houver handoff pendente de contract-writer, usá-lo automaticamente.
   Se não: pedir ao usuário o path do brief ou contexto.

2. **Verificar contexto mínimo:**
   - `empresa` — identificada
   - `escopo_esperado` — ao menos parcialmente declarado
   - `contato_principal` — para personalizar o destinatário

   Se contexto insuficiente:
   ```
   ⚠️ HALT — Não há contexto suficiente sobre o escopo do projeto.
   
   Para gerar o kit de onboarding preciso de:
   - Escopo do projeto (o que será feito)
   - Nome e contato do responsável no cliente
   
   Forneça via @brief-extractor *extract ou cole o contexto diretamente.
   ```

3. **Detectar tipo de projeto** (ver tabela acima).

4. **Ler os templates** de `squads/client-onboarding/templates/onboarding/`.

---

## Passo 2 — Gerar kit seção a seção

### Seção 01 — Boas-vindas

Tom: acolhedor, direto, orientado à parceria. Evitar linguagem corporativa genérica.

```markdown
## Bem-vindo(a) à bordo, {contato_principal}!

Estamos muito felizes em começar este projeto com {empresa}.

Nas próximas {N} semanas, vamos {objetivo principal do projeto em 1-2 frases}.

Este documento reúne tudo o que você precisa saber para os primeiros dias:
o que fazer agora, o que precisamos de você, como vai funcionar a comunicação
e o que esperar ao longo do projeto.

Qualquer dúvida, fale com a gente — estamos aqui.
```

### Seção 02 — Próximos Passos

O que o cliente deve fazer imediatamente após receber o kit.
Formato: checklist com prazo.

```markdown
## O que fazer agora

Nos próximos {N} dias:

- [ ] Confirmar recebimento deste documento respondendo este e-mail
- [ ] Agendar a reunião de kickoff — {link/contato para agendar}
- [ ] {ação específica do projeto — ex: "Criar conta na plataforma X e compartilhar acesso"}
- [ ] {ação específica — ex: "Enviar material de identidade visual"}
- [ ] Revisar e assinar o termo de aceite dos acessos (se aplicável)

Se houver qualquer impedimento para esses passos, nos avise com antecedência.
```

Personalizar as ações específicas ao tipo de projeto.

### Seção 03 — Acessos e Informações Necessárias

O que o cliente precisa nos enviar para que o projeto comece.

```markdown
## O que precisamos de você

Para iniciarmos o projeto, precisamos dos seguintes acessos e materiais:

### Acessos
{lista por tipo de projeto — exemplos:}
- [ ] Acesso ao repositório: {especificar nível — leitura/escrita}
- [ ] Credenciais da plataforma: {nome da plataforma}
- [ ] Acesso ao Google Analytics / painel de métricas
- [ ] Acesso administrativo ao {sistema relevante}

### Materiais e Documentos
- [ ] {material específico — ex: "Manual de marca (logo, cores, tipografia)"}
- [ ] {material específico — ex: "Base de dados de clientes para migração"}
- [ ] {material específico — ex: "Contratos ou documentos de referência"}

### Informações
- [ ] {informação específica — ex: "Lista de usuários que terão acesso ao sistema"}
- [ ] {informação específica — ex: "Calendário de indisponibilidade da equipe"}

**Como enviar:** {canal de preferência — ex: "Por e-mail para contato@empresa.com" ou "Via Google Drive na pasta compartilhada"}
```

Personalizar ao tipo de projeto. Para projetos de desenvolvimento: focar em acessos técnicos.
Para consultoria: focar em documentos analíticos e dados históricos.

### Seção 04 — Cronograma Inicial (recomendado)

```markdown
## Cronograma das Primeiras Semanas

| Semana | Foco | O que acontece |
|--------|------|----------------|
| Semana 1 | Kickoff e Discovery | Reunião de alinhamento, coleta de acessos |
| Semana 2 | {fase inicial do projeto} | {descrição breve} |
| Semana {N} | {fase seguinte} | {descrição breve} |
| Semana {N+1} | Primeira entrega | {entregável 1} pronto para revisão |

**Datas sujeitas a ajuste** — cronograma confirmado na reunião de kickoff.
```

Derivar semanas do `prazo_esperado` do brief. Se prazo não definido: usar estrutura genérica e marcar `[CONFIRMAR NO KICKOFF]`.

### Seção 05 — Contatos e Canais

```markdown
## Quem contatar e como

### Responsáveis pelo projeto

**Do nosso lado:**
- **Responsável principal:** {nome} — {e-mail} — {telefone/WhatsApp se aplicável}
- **Suporte técnico (se aplicável):** {nome ou canal}

**Do seu lado:**
- **Interlocutor:** {contato_principal do brief} — confirmar no kickoff

### Canais de comunicação

| Tipo | Canal | Prazo de resposta |
|------|-------|-------------------|
| Dúvidas e atualizações | {canal — ex: WhatsApp/Slack/E-mail} | {N} horas úteis |
| Revisões e feedbacks | {canal — ex: E-mail} | {N} dias úteis |
| Urgências | {canal — ex: Telefone} | Imediato durante horário comercial |

**Horário de atendimento:** {dias e horário | "Segunda a sexta, 9h–18h (Brasília)"}
```

### Seção 06 — O que esperar (recomendado)

```markdown
## O que esperar nas primeiras semanas

**Como trabalhamos:**
- {método de trabalho — ex: "Entregamos em sprints de 2 semanas com ciclos de revisão"}
- {processo de aprovação — ex: "Cada entrega tem {N} dias para feedback — silêncio = aceite"}
- {comunicação proativa — ex: "Atualizações de progresso toda sexta-feira por e-mail"}

**O que você vai receber:**
- {ex: "Relatório semanal de progresso"}
- {ex: "Acesso ao board de tarefas para acompanhar em tempo real"}
- {ex: "Demonstração da primeira versão na semana {N}"}

**O que pode atrasar o projeto:**
- Atraso no envio dos acessos e materiais da seção 3
- Feedback fora do prazo nas revisões
- Mudanças de escopo significativas após o início
```

### Seção 07 — FAQ (opcional)

Incluir apenas se o projeto tiver dúvidas recorrentes previsíveis (projetos mais complexos, clientes com histórico de perguntas similares).

```markdown
## Perguntas Frequentes

**Quando vou ver o primeiro resultado?**
{resposta específica ao cronograma do projeto}

**Como solicitar ajustes durante o projeto?**
{processo de change request | "Via e-mail para {contato} — avaliamos impacto em prazo e custo"}

**O que acontece se eu precisar mudar o escopo?**
{política de mudança de escopo | "Mudanças de escopo são avaliadas caso a caso — apresentamos impacto antes de executar"}
```

---

## Passo 3 — Personalizar ao cliente e ao tipo de projeto

Após gerar as seções base, revisar e ajustar:

1. **Tom:** clientes grandes → mais formal. Clientes pequenos/startups → mais descontraído.
2. **Detalhamento técnico:** projeto técnico → expandir seção de acessos. Consultoria → expandir seção de materiais.
3. **Cronograma:** derivar sempre do brief — se prazo não definido, marcar `[CONFIRMAR NO KICKOFF]`.
4. **Seções opcionais:** omitir FAQ se projeto é simples. Incluir seção de expectativas se cliente é novo.

---

## Passo 4 — Salvar

### Estrutura do documento final

```markdown
# Kit de Onboarding — {Empresa}

**Data:** YYYY-MM-DD
**Elaborado por:** @onboarding-writer (Ori)

---

{seção 01 — boas-vindas}
{seção 02 — próximos passos}
{seção 03 — acessos necessários}
{seção 04 — cronograma — se aplicável}
{seção 05 — contatos}
{seção 06 — expectativas — se aplicável}
{seção 07 — faq — se aplicável}

---

*Kit gerado por @onboarding-writer — revisar antes de entregar ao cliente*
```

### Salvar o arquivo

```
data/outputs/client-onboarding/onboarding/onboarding-writer_kit-{empresa}-{INSTANCE}-YYYY-MM-DD.md
```

### Confirmar ao usuário

```
✅ Kit de onboarding salvo:
   data/outputs/client-onboarding/onboarding/onboarding-writer_kit-{empresa}-{INSTANCE}-YYYY-MM-DD.md

Seções geradas: {lista das seções incluídas}
Tipo de projeto detectado: {tipo}

Pipeline client-onboarding concluído para {empresa}.
```
