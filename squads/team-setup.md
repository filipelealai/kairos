# Acesso ao Kairos via Claude Desktop

Este guia é para membros do time que vão usar os squads do Kairos sem instalar nada no computador além do **Claude Desktop**. Toda a infraestrutura roda no servidor — você só interage por uma interface de chat.

---

## O que você vai conseguir fazer

- Conversar com qualquer agente operacional dos squads (`@brief-extractor`, `@proposal-writer`, `@email-writer`, etc.)
- Gerar outputs (briefs, propostas, contratos, kits de onboarding, e-mails) que aparecem automaticamente em uma pasta no Google Drive
- Continuar pipelines começados por outro membro do time (handoffs)

## O que você NÃO vai conseguir fazer (e está tudo bem)

- Modificar o framework Kairos
- Criar novos squads ou agentes
- Acessar comandos de governança (`*new-story`, `*push`, etc.)

Essas são responsabilidades do dono do framework, não do uso operacional.

---

## Setup — passo a passo

### 1. Instale o Claude Desktop

- **Mac:** baixe em https://claude.ai/download e arraste para Applications
- **Windows:** baixe em https://claude.ai/download e execute o instalador

Faça login com sua conta Claude (qualquer plano funciona — o servidor não precisa do seu plano para a maior parte do trabalho, mas a geração de texto consome créditos seu).

### 2. Receba a API key do Kairos

A pessoa responsável pelo Kairos (provavelmente Filipe) vai te passar uma chave de API privada. Guarde-a em um local seguro — ela dá acesso aos squads.

### 3. Configure o servidor MCP no Claude Desktop

Abra o arquivo de configuração do Claude Desktop:

- **Mac:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

Se o arquivo não existir, crie-o. Cole o conteúdo abaixo (substituindo `COLE_AQUI_SUA_API_KEY` pela chave que você recebeu):

```json
{
  "mcpServers": {
    "kairos": {
      "url": "https://kairos.vendoteca.com/mcp",
      "headers": {
        "Authorization": "Bearer COLE_AQUI_SUA_API_KEY"
      }
    }
  }
}
```

Salve o arquivo e **feche e reabra o Claude Desktop completamente** (não apenas a janela — saia do app e abra de novo).

### 4. Verifique se o servidor está disponível

No Claude Desktop, comece uma nova conversa e clique no ícone de "+" ou "/" da caixa de mensagem. Você deve ver uma seção chamada **kairos** com vários prompts disponíveis (um por agente). Por exemplo:

- `kairos-cold-prospecting-email-writer` — gerar e-mails de prospecção
- `kairos-client-onboarding-brief-extractor` — extrair brief estruturado
- `kairos-client-onboarding-proposal-writer` — gerar proposta comercial
- `kairos-sales-pipeline-pre-call` — preparar brief para call

Se essa seção não aparecer, veja o **troubleshooting** no fim deste guia.

---

## Como usar um agente

### Fluxo padrão

1. **Comece uma nova conversa** no Claude Desktop
2. **Selecione o prompt do agente** que você quer usar (`/` → `kairos-...`)
3. O Claude vai carregar o contexto completo do agente (persona, regras, memória, templates)
4. **Escreva o que você precisa** em linguagem natural — ex: "preciso de um brief para a empresa ACME, vendem software de RH, conversei com o CEO ontem por WhatsApp e ele disse..."
5. O Claude vai trabalhar como aquele agente, fazer perguntas se faltar informação, e gerar o output
6. **Confirmar para salvar** — quando o agente perguntar "posso salvar?", confirme. O output vai pra `data/outputs/{squad}/...` no servidor E pra pasta correspondente no Google Drive automaticamente

### Onde os outputs aparecem

Pasta compartilhada no Google Drive (link te será passado junto com a API key). Estrutura:

```
Kairos Outputs/
├── cold-prospecting/
│   ├── emails/
│   ├── reports/
│   └── ...
├── sales-pipeline/
│   ├── briefs/
│   └── ...
└── client-onboarding/
    ├── briefs/
    ├── proposals/
    ├── contracts/
    └── onboarding/
```

### Cada conversa começa do zero

O Claude Desktop **não mantém memória entre conversas**. Cada vez que você abrir uma conversa nova, precisa selecionar o prompt do agente de novo. Isso é por design — garante que o contexto está sempre fresco e atualizado com o que está no servidor.

---

## Boas práticas

**Use o agente certo.** Cada agente tem responsabilidade específica:

- `@brief-extractor` — só estrutura informação, não gera proposta
- `@proposal-writer` — só gera proposta a partir de brief existente
- `@contract-writer` — só redige rascunho de contrato (você precisa revisar juridicamente)
- `@onboarding-writer` — só gera kit de onboarding pós-assinatura

**Forneça contexto rico no início.** Quanto mais informação você der no primeiro prompt, melhor o output. Pode colar transcrição de call, mensagens do cliente, anotações suas — o agente sabe extrair o que precisa.

**Não tente burlar o agente.** Se ele recusa (ex: contract-writer não declara "versão final" sem revisão jurídica), há uma razão. As restrições estão na persona dele.

**Ao gerar contrato, sempre marque [REVISAR JURIDICAMENTE]** antes de mandar para o cliente. Os templates são baseados em legislação brasileira genérica — casos específicos podem precisar de ajuste.

---

## Troubleshooting

### O servidor "kairos" não aparece no menu de prompts

1. Verifique se o JSON de config está sintaticamente válido (use https://jsonlint.com)
2. Confirme que a URL é exatamente `https://kairos.vendoteca.com/mcp`
3. Confirme que a API key começa com `Bearer ` no header
4. Feche o Claude Desktop **completamente** (no Mac: Cmd+Q) e reabra
5. Se ainda assim não aparecer, peça ajuda ao Filipe

### "401 Unauthorized" ou "servidor não responde"

Confirme com o Filipe se a API key ainda é válida. Pode ter sido rotacionada.

### Agente não consegue salvar output

Verifique se o e-mail da Service Account do Drive ainda tem permissão na pasta. Se o erro persiste, peça ajuda.

### Output não apareceu no Drive

- Pode levar alguns segundos
- Verifique se você está olhando a pasta certa (use o link compartilhado, não navegue manualmente)
- Se o output saiu na conversa mas não no Drive, peça ao Filipe pra verificar logs do servidor

### O agente parou no meio de uma resposta longa

Continue a conversa pedindo "continue" — o Claude Desktop tem limite por mensagem mas mantém contexto na conversa.

---

## Quem é responsável pelo quê

| Coisa | Quem cuida |
|-------|-----------|
| Servidor MCP funcionando, atualizado, com Drive sync | Filipe (dono do framework) |
| Sua API key, segurança da sua conta Claude | Você |
| Qualidade do que você pede aos agentes | Você |
| Personas dos agentes, regras, templates | Filipe (via desenvolvimento no Kairos) |
| Outputs salvos no Drive — você é dono do que gerou | Você |

Em caso de dúvida que não está aqui: pergunte ao Filipe.
