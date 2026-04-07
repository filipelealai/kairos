---
task: Write Emails
responsavel: "@email-writer"
responsavel_type: agent
atomic_layer: personalization
elicit: false
Entrada: |
  - n_emails: quantidade de e-mails a gerar (argumento do *write N)
  - webhook_url: URL do webhook n8n (ENV N8N_LEADS_URL)
  - filtro: Pode disparar = SIM AND Status do Envio IN ("", "NÃO ENVIADO") AND Email não vazio
Saida: |
  - emails_file: data/emails/emails-YYYY-MM-DD.json (apenas no modo *write)
  - handoff: .kairos/handoffs/handoff-email-writer-to-campaign-analyst-{ts}.yaml (apenas no modo *write)
Checklist:
  - "[ ] Buscar leads via webhook e filtrar pendentes"
  - "[ ] Detectar e marcar emails suspeitos (domínio sem relação com a empresa)"
  - "[ ] Para emails suspeitos: escrever mensagem neutra de redirecionamento"
  - "[ ] Para cada lead válido: primeiro parágrafo cria reconhecimento? Se não, reescrever"
  - "[ ] Verificar: nenhum e-mail abre com 'Oi, [nome]!' + pitch imediato"
  - "[ ] Verificar: nenhum e-mail tem mais de um travessão"
  - "[ ] Verificar: CTAs variam entre os e-mails do batch"
  - "[ ] Verificar: tamanho varia (2 a 4 parágrafos, não todos iguais)"
  - "[ ] Salvar JSON (modo *write) ou apenas exibir (modo *preview)"
  - "[ ] Exibir preview com destaque para suspeitos"
  - "[ ] Gerar handoff para @campaign-analyst (modo *write)"
---

# Write Emails Task

## Propósito

Gerar e-mails de prospecção personalizados por empresa — mensagens diretas de Filipe Leal para donos de negócio, como se fossem escritas por uma pessoa real para outra.

---

## Execução

### Passo 1 — Buscar e filtrar leads

```bash
curl -s https://n8n.vendoteca.com/webhook/kairos-leads
```

Filtre:
- `Pode disparar = SIM`
- `Status do Envio` vazio ou `NÃO ENVIADO`
- Email não vazio

Pegue os primeiros N.

### Passo 2 — Detectar emails suspeitos

Antes de gerar qualquer e-mail, verifique o domínio de cada lead.

**Email suspeito** = domínio do e-mail não tem relação óbvia com o nome da empresa.

Padrões suspeitos para empresas de beleza/saúde:
- `@contabilidade.com.br`, `@mpconsult.com`, `@escritoriofiscal.net`
- Domínio genérico que não aparece no nome da empresa

**Para emails suspeitos:** escreva uma mensagem curta e neutra:
```
Assunto: Mensagem para o responsável por [atividade]
Corpo: Olá, estou tentando entrar em contato com a equipe da [empresa].
Se puder repassar esta mensagem ou me indicar o contato correto, agradeço.
[assinatura]
```

Marque `email_suspeito: true` no JSON.

### Passo 3 — Gerar e-mails personalizados

Para cada lead válido, escreva um e-mail seguindo estes princípios:

#### O que NUNCA fazer

- Não abra com "Oi, [nome]!" seguido imediatamente de pitch
- Não use cidade e estado no assunto no formato "Negócio em Cidade"
- Não use travessão (—) mais de uma vez por e-mail
- Não use "Faço automação de...", "Configuro um sistema que...", "Tenho um sistema que..."
- Não termine toda frase com reticências ou exclamação
- Não feche todos os e-mails com a mesma frase
- Não descreva o serviço de forma técnica antes de o leitor se reconhecer no problema

#### O que fazer

- Comece de um lugar inesperado: uma pergunta, uma observação, uma cena do dia a dia
- O primeiro parágrafo deve fazer o leitor pensar "é exatamente isso" — se não fizer isso, reescreva
- Use linguagem de conversa, não de proposta comercial
- Varie o tamanho: 2 a 4 parágrafos — nunca todos com a mesma estrutura
- Varie o tom conforme o perfil do negócio
- A CTA pode ser qualquer coisa que soe natural — não precisa ser pergunta direta
- Capital social como sinal de maturidade: R$1k = MEI iniciante, R$100k+ = negócio estabelecido

#### Ângulos por tipo de negócio

**Barbearia:** fila invisível, cliente que não volta, cancelamento em cima da hora
**Salão/cabeleireiro:** "qual o preço?" no WhatsApp o dia inteiro, agenda morta na quarta
**Clínica estética médica:** triagem que consome tempo da profissional, no-show
**Estética não-médica:** concorrência por preço, cliente que não volta sem lembrete
**Esmalteria:** volume alto, ticket baixo, agenda cheia o dia todo
**Solo/MEI:** faz tudo sozinha, não consegue responder mensagem durante atendimento

### Passo 4 — Montar o JSON

```json
[
  {
    "row_number": 123,
    "cnpj": "XX.XXX.XXX/XXXX-XX",
    "email": "contato@empresa.com",
    "nome": "Nome Limpo da Empresa",
    "email_suspeito": false,
    "assunto": "Assunto específico (max 60 chars)",
    "corpo": "<p>Parágrafo 1</p><p>Parágrafo 2</p>"
  }
]
```

### Passo 5 — Salvar e exibir

**Modo *write:** salve em `data/emails/emails-YYYY-MM-DD.json`
**Modo *preview:** não salve — apenas exiba

**Exibição do preview:**
```
━━━ [N/TOTAL] Nome da Empresa ━━━━━━━━━━━━━━━━━━━━━━━━
Para:    email@empresa.com
Assunto: Assunto do e-mail
⚠️ EMAIL SUSPEITO  (se aplicável)

Texto do corpo sem tags HTML...
```

**Resumo final:**
```
✓ X e-mails gerados
⚠ Y e-mails suspeitos
Salvo em: data/emails/emails-YYYY-MM-DD.json
```

### Passo 6 — Gerar handoff (modo *write)

Salve em `.kairos/handoffs/handoff-email-writer-to-campaign-analyst-{timestamp}.yaml`:

```yaml
handoff:
  from_agent: email-writer
  to_agent: campaign-analyst
  last_command: write
  timestamp: "{ISO timestamp}"
  consumed: false
  context:
    emails_file: "data/emails/emails-YYYY-MM-DD.json"
    total_gerados: N
    total_suspeitos: N
  next_action: "Analisar métricas após o disparo com *analyze"
```

---

## Blocking

- Webhook indisponível → HALT
- 0 leads pendentes → HALT, informe o usuário
- Algum e-mail com primeiro parágrafo que não cria reconhecimento → reescrever antes de salvar
