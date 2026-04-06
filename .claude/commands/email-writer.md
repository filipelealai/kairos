Gere e-mails de prospecção personalizados para os próximos leads da fila.

Argumento: `$ARGUMENTS` (número de e-mails a gerar, padrão: 10)

## Passo 1 — Buscar leads

```bash
curl -s https://n8n.vendoteca.com/webhook/kairos-leads
```

Filtre: `Pode disparar = SIM` e `Status do Envio` vazio ou `NÃO ENVIADO`. Pegue os primeiros $ARGUMENTS (ou 10).

## Passo 2 — Gerar os e-mails

Para cada lead, escreva um e-mail como se fosse uma pessoa real escrevendo para outra pessoa real. Não é campanha de marketing. É uma mensagem direta de Filipe Leal para o dono do negócio.

### O que NUNCA fazer

- Não abra com "Oi, [nome]!" seguido imediatamente de pitch. Isso é padrão de robô.
- Não use o nome da cidade no assunto no formato "Negócio em Cidade: [proposta]".
- Não use travessão como recurso estilístico recorrente. No máximo um por e-mail.
- Não use "Faço automação de...", "Configuro um sistema que...", "Tenho um sistema que...". Isso soa como folder de vendedor.
- Não termine toda frase com reticências ou ponto de exclamação.
- Não feche todos os e-mails com a mesma frase ("Quer ver na prática?", "É só responder", "Sem compromisso").
- Não mencione cidade e estado na mesma frase como localização. Se mencionar cidade, que seja com propósito — contexto de mercado, não endereço.
- Não descreva o serviço de forma técnica antes de fazer o leitor se reconhecer no problema.

### O que fazer

- Comece de um lugar inesperado: uma pergunta, uma observação, uma situação específica que o leitor vai reconhecer como real no dia a dia dele.
- O primeiro parágrafo deve fazer o leitor pensar "é exatamente isso". Se não fizer isso, reescreva.
- Use linguagem de conversa, não de proposta comercial. Como você falaria pessoalmente.
- Varie o tamanho: alguns e-mails podem ter 2 parágrafos, outros 4. Não todos com 4.
- Varie o tom dependendo do perfil: médica estéticista recebe linguagem diferente de dono de barbearia de bairro.
- Use o nome da empresa com naturalidade — não como etiqueta, mas como referência real.
- A CTA pode ser qualquer coisa que soe natural: uma pergunta, uma oferta específica, uma afirmação que convida resposta. Não precisa ser pergunta direta sempre.
- Considere o capital social como sinal de maturidade: R$1k é MEI iniciante, R$100k é negócio estabelecido. Tom diferente.

### Ângulos por tipo de negócio (use como inspiração, não template)

- **Barbearia**: fila invisível, cliente que não volta, pico de fim de semana, cancelamento em cima da hora
- **Salão/cabeleireiro**: "qual o preço?" no WhatsApp o dia inteiro, cliente que pergunta e some, dificuldade de manter agenda cheia em dia de semana
- **Clínica estética (Dra./médica)**: triagem que gasta tempo da profissional, no-show, cliente que pesquisa muito antes de decidir
- **Estética (não-médica)**: concorrência por preço, cliente que não volta sem lembrete, dificuldade de vender pacotes
- **Esmalteria**: volume alto, ticket baixo, precisa de agenda cheia o dia todo
- **Solo/MEI**: faz tudo sozinha, não tem como parar pra responder mensagem durante atendimento

## Passo 3 — Salvar

Salve em `data/emails/emails-YYYY-MM-DD.json`:

```json
[
  {
    "row_number": 123,
    "cnpj": "...",
    "email": "...",
    "nome": "...",
    "email_suspeito": false,
    "assunto": "...",
    "corpo": "...html com <p>..."
  }
]
```

Marque `email_suspeito: true` se o domínio do e-mail não tem relação óbvia com o nome da empresa (ex: `financeiro@contabilidade.com.br` para uma barbearia).

## Passo 4 — Exibir

Mostre o preview de cada e-mail: assunto + corpo em texto puro (sem tags HTML). Destaque os marcados como suspeitos.
