# IDS — Princípios de Criação: Reutilizar > Adaptar > Criar

## O Princípio

Antes de criar qualquer novo artefato (agente, task, script, rule), percorra a hierarquia:

```
REUTILIZAR → ADAPTAR → CRIAR
```

Criar é sempre a última opção. O custo de manutenção de um novo artefato é real e permanente.

---

## As Três Camadas

### 1. REUTILIZAR — existe algo que já faz isso?

Verifique antes de qualquer nova criação:

| Preciso de... | Checar primeiro |
|---------------|-----------------|
| Novo agente | `.claude/commands/kairos/agents/` — algum agente existente cobre com novo comando? |
| Nova task | `.kairos-core/tasks/` — alguma task existente pode ser reutilizada? |
| Novo script | `src/agents/` — algum script existente aceita parâmetros diferentes? |
| Nova rule | `.claude/rules/` — alguma rule existente já define isso? |
| Novo squad | `squads/` — algum squad existente pode ser expandido? |

Se REUTILIZAR é possível → **pare aqui, não crie nada novo**.

---

### 2. ADAPTAR — existe algo próximo que pode ser estendido?

Se nada reutilizável existe, verifique se algo pode ser adaptado:

| Situação | Adaptação preferida |
|----------|-------------------|
| Task existente cobre 80% | Adicionar seção ou modo na task existente |
| Agente existente tem escopo adjacente | Adicionar novo comando (`*novo-comando`) ao agente |
| Script produz output errado | Paramerizá-lo ou adicionar flag, não criar novo |
| Rule cobre caso similar | Estender a rule com nova subseção |

Adaptação deve ser **retrocompatível** — não quebra o uso existente.

---

### 3. CRIAR — apenas quando REUTILIZAR e ADAPTAR claramente não encaixam

Critérios para justificar criação de novo artefato:

1. **Responsabilidade nova e distinta** — não sobrepõe nada existente
2. **Contexto de uso diferente** — operação em dados, timing ou squad diferente
3. **Nenhuma adaptação razoável existe** — estender o existente resultaria em gambiarra
4. **Tem donodefinido** — sabe quem governa o novo artefato e qual squad pertence

Ao criar, registrar no CHANGELOG e bump de versão obrigatório (MINOR ou MAJOR).

---

## Aplicação por Tipo de Artefato

### Novo agente (persona + script)

```
1. Existe agente com escopo parcialmente sobreposto? → ADAPTAR com novo comando
2. O squad tem task que cobre parte? → REUTILIZAR task, não criar agente
3. A responsabilidade é genuinamente nova e distinta? → CRIAR (story obrigatória)
```

### Nova task

```
1. Alguma task existente pode ser chamada com contexto diferente? → REUTILIZAR
2. A task existente pode receber novo bloco de instruções? → ADAPTAR
3. É uma responsabilidade completamente nova? → CRIAR (pode ser PATCH se pequena)
```

### Novo script TypeScript

```
1. O script existente aceita parâmetros diferentes? → REUTILIZAR com parâmetro
2. Pode adicionar modo/flag ao script existente? → ADAPTAR
3. Computação completamente diferente? → CRIAR em src/agents/
```

### Nova rule

```
1. Alguma rule existente define algo próximo? → ADAPTAR com nova seção
2. É realmente um princípio novo e orthogonal? → CRIAR
```

---

## Antipadrões a Evitar

- ❌ Criar agente novo quando um comando novo no agente existente resolve
- ❌ Criar script novo quando o existente pode ser parametrizado
- ❌ Criar task nova para variação marginal de task existente
- ❌ Criar squad novo para funcionalidade que é extensão do squad atual
- ❌ Criar rule nova que repete princípio já coberto por outra rule

---

## Exemplo de Aplicação

**Cenário:** Preciso de um agente que analise métricas de e-mails enviados (open rate, bounce).

```
1. REUTILIZAR? @campaign-analyst já analisa campanha. Esse seria um modo "*analyze-results".
   → Adaptar @campaign-analyst com novo comando, não criar @metrics-analyst.

2. Se o escopo crescer muito (dashboard completo, comparações históricas, alertas):
   → Avaliar squad novo (com story MAJOR).
```
