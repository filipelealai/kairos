---
kairos-owned: true
kairos-version: 3.10.0
id: kairos-kb
title: Knowledge Base do Kairos
agent: kairos
command: "*kb [{tópico}]"
version: 1
---

# Task: kairos-kb

## Propósito

Expor e gerenciar a base de conhecimento curada do Kairos em `.kairos-core/data/kairos-kb.md`.

---

## Execução

### Modo 1: `*kb` — Listar tópicos disponíveis

1. Ler `.kairos-core/data/kairos-kb.md`
2. Extrair o Índice (seção `## Índice`)
3. Exibir tópicos disponíveis com descrição de uma linha
4. Exibir: "Use `*kb {tópico}` para ver detalhes — ex: `*kb decisoes`"

**Tópicos disponíveis:**
- `decisoes` — Decisões arquiteturais registradas
- `integracoes` — Integrações externas: gotchas, campos e configurações
- `naming` — Convenções de nomenclatura
- `erros` — Erros comuns e soluções
- `padroes` — Padrões validados e boas práticas
- `referencias` — Fluxos e pipelines de referência rápida

---

### Modo 2: `*kb {tópico}` — Exibir tópico específico

1. Mapear argumento para seção no KB:

   | Argumento | Seção |
   |-----------|-------|
   | `decisoes`, `arch`, `arquitetura` | `## Decisões Arquiteturais` |
   | `integracoes`, `integrações`, `dados` | `## Integrações` |
   | `naming`, `nomenclatura`, `nomes` | `## Convenções de Naming` |
   | `erros`, `bugs`, `problemas` | `## Erros Comuns` |
   | `padroes`, `validados` | `## Padrões Validados` |
   | `referencias`, `pipelines`, `fluxos` | `## Referências Rápidas` |

2. Ler e exibir a seção correspondente
3. Se argumento não mapeado: listar tópicos disponíveis (fallback para Modo 1)

---

### Modo 3: `*kb add` — Adicionar nova entrada

**Elicitação guiada:**

1. Perguntar: "Em qual tópico? (decisoes / integracoes / naming / erros / padroes / referencias)"
2. Perguntar: "Qual o título/cabeçalho da entrada?"
3. Perguntar: "Qual o conteúdo? (decisão tomada, gotcha encontrado, padrão validado...)"
4. Perguntar: "Contexto: por que isso merece estar no KB?"
5. Mostrar preview da entrada formatada
6. Confirmar: "Adicionar ao KB? (s/n)"
7. Se confirmado: editar `.kairos-core/data/kairos-kb.md` adicionando na seção correta
8. Atualizar "Última atualização" no rodapé do KB

**Regras de qualidade para entrada:**
- Entrada deve ser **acionável** — não apenas "é assim", mas "faça X porque Y"
- Deve ter **contexto suficiente** para ser entendida sem a conversa original
- Se for decisão arquitetural: incluir **trade-off aceito**
- Se for gotcha: incluir **solução concreta**

---

## Blocking

- HALT se KB não encontrado em `.kairos-core/data/kairos-kb.md` — informar ao usuário

---

## Completion

- Exibir a informação solicitada (Modo 1 e 2) ou confirmar adição (Modo 3)
- Sem handoff (KB é acesso sob demanda, não parte de pipeline)
