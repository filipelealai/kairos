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

Faça login com sua conta Claude (qualquer plano funciona — o servidor não precisa do seu plano para a maior parte do trabalho, mas a geração de texto consome créditos seus).

### 2. Instale Node.js (Windows e Mac)

O Claude Desktop atualmente **não suporta servidor MCP remoto via URL diretamente** — precisa de um pequeno bridge local chamado `mcp-remote`, que roda em Node.js. Pode parecer chato mas é uma única instalação.

- **Verifique se já tem Node:** abra o Prompt de Comando (Windows) ou Terminal (Mac) e rode:
  ```
  node --version
  ```
  Se aparecer `v20.x.x`, `v22.x.x` ou maior, pula pra etapa 3.
- **Se não tem Node:** baixe o instalador LTS em https://nodejs.org/ e instale com as opções padrão. Depois feche e abra o Prompt/Terminal de novo, repita `node --version` pra confirmar.

### 3. Receba a API key do Kairos

A pessoa responsável pelo Kairos (provavelmente Filipe) vai te passar uma chave de API privada. Guarde-a em um local seguro — ela dá acesso aos squads.

### 4. Configure o servidor MCP no Claude Desktop

A forma mais confiável é deixar o próprio app abrir o arquivo de configuração:

1. Abra o Claude Desktop
2. **Settings** (engrenagem, ou `Ctrl+,` no Windows / `Cmd+,` no Mac)
3. Aba **Developer**
4. Clique em **Edit Config** — abre o arquivo certo no editor de texto padrão e cria a pasta + arquivo se não existirem

> Se a aba **Developer** não aparece: vá em `Settings → Help` e habilite "Enable developer mode" (ou atualize o Claude Desktop pra versão ≥ 0.7).

**Substitua todo o conteúdo** do arquivo (o JSON precisa ter um único objeto top-level) pelo abaixo, trocando `COLE_AQUI_SUA_API_KEY` pela chave que você recebeu.

**Windows:**
```json
{
  "mcpServers": {
    "kairos": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "mcp-remote",
        "https://kairos.vendoteca.com/mcp",
        "--header",
        "Authorization: Bearer COLE_AQUI_SUA_API_KEY"
      ]
    }
  }
}
```

**Mac:**
```json
{
  "mcpServers": {
    "kairos": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://kairos.vendoteca.com/mcp",
        "--header",
        "Authorization: Bearer COLE_AQUI_SUA_API_KEY"
      ]
    }
  }
}
```

Salve o arquivo e **feche e reabra o Claude Desktop completamente** (no Mac, `Cmd+Q`; no Windows, botão direito no ícone da system tray → Quit). A primeira inicialização demora 10-30s porque baixa o pacote `mcp-remote`.

### 5. Verifique se o servidor está disponível

No Claude Desktop, abra uma nova conversa e clique no botão **"+"** ao lado da caixa de mensagem. No menu que abrir:

- **Conectores** (Connectors)
- → **Adicionar do kairos** (Add from kairos) — submenu

Deve aparecer a lista dos 10 agentes operacionais:

- `Kairos-cold-prospecting-campaign-analyst`
- `Kairos-cold-prospecting-lead-scorer`
- `Kairos-cold-prospecting-niche-classifier`
- `Kairos-cold-prospecting-email-writer`
- `Kairos-sales-pipeline-pre-call`
- `Kairos-sales-pipeline-call-analyst`
- `Kairos-client-onboarding-brief-extractor`
- `Kairos-client-onboarding-proposal-writer`
- `Kairos-client-onboarding-contract-writer`
- `Kairos-client-onboarding-onboarding-writer`

Se essa seção não aparecer, veja o **troubleshooting** no fim deste guia.

---

## Como usar um agente

### Fluxo padrão

1. **Comece uma nova conversa** no Claude Desktop
2. Clique no **"+"** ao lado da caixa de mensagem → **Conectores** → **Adicionar do kairos** → selecione o agente que você quer usar
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

### O servidor "kairos" não aparece em Conectores

1. Verifique se o JSON de config está sintaticamente válido — não pode ter conteúdo antes ou depois do objeto principal (use https://jsonlint.com pra validar)
2. Confirme que a URL é exatamente `https://kairos.vendoteca.com/mcp`
3. Confirme que a API key foi copiada inteira no header `Authorization: Bearer ...`
4. Confirme que tem Node.js instalado: rode `node --version` no Prompt de Comando — precisa retornar uma versão
5. Feche o Claude Desktop **completamente** (no Mac: Cmd+Q; no Windows: botão direito system tray → Quit) e reabra. A primeira inicialização demora 10-30s baixando o `mcp-remote`
6. Confirme em `Settings → Developer` se o servidor `kairos` aparece como "running"
7. Se ainda assim não aparecer, peça ajuda ao Filipe e mande os logs em `%APPDATA%\Claude\logs\mcp*.log` (Windows) ou `~/Library/Logs/Claude/mcp*.log` (Mac)

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
