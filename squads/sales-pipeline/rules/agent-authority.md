# sales-pipeline — Matriz de Autoridade

Matriz de autoridade dos agentes do squad sales-pipeline. Autoridade do @kairos e regras universais vivem em `.claude/rules/agent-authority.md`.

---

## @pre-call (Rex) — Preparação Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Gerar brief pré-call (`*brief`) | EXCLUSIVA |
| Ler dados de leads do Google Sheets / webhook cold-prospecting | AUTORIZADO |
| Modificar dados de leads | BLOQUEADA |
| Analisar transcrições de call | BLOQUEADA |
| Atualizar Trello | BLOQUEADA |

---

## @call-analyst (Cal) — Análise Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Analisar transcrições de call (`*analyze`) | EXCLUSIVA |
| Criar/atualizar cards no Trello | EXCLUSIVA |
| Gerar rascunho de follow-up (`*followup`) | EXCLUSIVA |
| Enviar e-mails diretamente | BLOQUEADA |
| Modificar dados de leads no Google Sheets | BLOQUEADA |

---

## Integração com Trello — Configuração

**Variáveis de ambiente obrigatórias** (definir em `.env`):

```
TRELLO_API_KEY=<chave da API — obtida em https://trello.com/app-key>
TRELLO_TOKEN=<token de acesso do usuário — gerado via OAuth na mesma página>
TRELLO_BOARD_ID=<ID do board de pipeline — obtido na URL do board ou via API>
```

**IDs das listas do pipeline** (obter via `trello-cli --get-lists $TRELLO_BOARD_ID`):

```
TRELLO_LIST_INTERESSE=<id>
TRELLO_LIST_PROPOSTA=<id>
TRELLO_LIST_NEGOCIACAO=<id>
TRELLO_LIST_NURTURE=<id>
TRELLO_LIST_FECHADO=<id>
TRELLO_LIST_PERDIDO=<id>
```

**Como obter o TRELLO_BOARD_ID:**
1. Abrir o board no Trello
2. Adicionar `.json` ao final da URL — ex: `https://trello.com/b/XXXX/meu-board.json`
3. Copiar o campo `id` do JSON retornado

**Como obter os IDs das listas:**
```bash
trello-cli --set-auth $TRELLO_API_KEY $TRELLO_TOKEN
trello-cli --get-lists $TRELLO_BOARD_ID
```
Mapear cada `name` ao env correspondente. Alternativa REST (sem CLI):
```
GET https://api.trello.com/1/boards/{TRELLO_BOARD_ID}/lists
    ?key={TRELLO_API_KEY}&token={TRELLO_TOKEN}&fields=id,name
```

**Interface primária:** `trello-cli` (ZenoxZX/trello-cli) — CLI instalado e configurado com `trello-cli --set-auth`.

**Fallback REST:** usar apenas se `trello-cli --check-auth` falhar. Base: `https://api.trello.com/1`.

**Operações autorizadas para @call-analyst:**

Via CLI (primário):
- `trello-cli --get-all-cards $TRELLO_BOARD_ID` — buscar cards existentes
- `trello-cli --create-card $TRELLO_LIST_{ESTAGIO} "{nome}" --desc "{desc}"` — criar card
- `trello-cli --move-card {card-id} $TRELLO_LIST_{ESTAGIO}` — mover card
- `trello-cli --update-card {card-id} --desc "{desc}"` — atualizar descrição

Via REST (fallback):
- `GET /boards/{id}/cards` — buscar cards existentes
- `POST /cards` — criar novo card
- `PUT /cards/{id}` — mover card de lista ou atualizar descrição

**Operações bloqueadas:**
- Deletar cards, boards ou listas
- Modificar membros ou permissões do board
- `trello-cli --delete-card`, `--archive-card` (exceto lixo explícito autorizado pelo usuário)

---

## Operações Universalmente Proibidas no Squad

- Enviar e-mails diretamente (sempre via revisão manual do usuário)
- Marcar deal como fechado sem confirmação explícita do usuário
- Modificar a planilha de leads do cold-prospecting

---

## Escalação Específica do Squad

| Situação | Ação |
|----------|------|
| Fonte de dados de leads indisponível | HALT — informar usuário |
| Transcrição incompleta ou ilegível | HALT — solicitar transcrição completa |
| Deal ambíguo entre nurture e perdido | HALT — consultar usuário antes de classificar |
| Follow-up pronto para envio | HALT — apresentar rascunho, não enviar |
