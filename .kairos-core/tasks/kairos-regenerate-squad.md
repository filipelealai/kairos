---
kairos-owned: true
kairos-version: 3.12.0
task: Kairos Regenerate Squad
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: scaffolding
elicit: false
Entrada: |
  - squad: nome do squad a regenerar (obrigatório)
    Formato: slug em kebab-case — ex: cold-prospecting
Saida: |
  - .claude/commands/kairos/agents/{id}.md regenerados (apenas personas com SHA drift)
  - marcador SHA atualizado em cada persona regenerada
Checklist:
  - "[ ] Validar que squads/{squad}/ existe"
  - "[ ] Listar todos os squads/{squad}/agents/*.yaml"
  - "[ ] Para cada YAML: calcular SHA atual"
  - "[ ] Para cada YAML: ler persona correspondente e extrair SHA do marcador"
  - "[ ] Para cada YAML com drift (ou sem persona): regenerar persona"
  - "[ ] Preservar seções entre <!-- kairos-custom-start --> e <!-- kairos-custom-end -->"
  - "[ ] Atualizar marcador SHA na persona regenerada"
  - "[ ] Reportar sumário"
---

# *regenerate-squad — Regeneração Incremental de Personas

Regenera as personas em `.claude/commands/kairos/agents/{id}.md` para os agentes de um squad cujo `.yaml` foi editado desde a última geração (SHA drift detectado).

A regeneração é **incremental**: apenas personas com drift são regeneradas. Personas sem marcador SHA (criadas antes da story 5.33) são ignoradas silenciosamente.

---

## Execução

### Passo 0 — Validar entrada

1. Verificar se `squads/{squad}/` existe no filesystem
   - Se não existir → **HALT**: "Squad '{squad}' não encontrado em squads/"
2. Listar todos os arquivos `squads/{squad}/agents/*.yaml`
   - Se nenhum encontrado → **HALT**: "Nenhum agente .yaml encontrado em squads/{squad}/agents/"

---

### Passo 1 — Detectar drift

Para cada arquivo `squads/{squad}/agents/{id}.yaml`:

1. Calcular SHA atual do YAML:
   ```bash
   sha256sum squads/{squad}/agents/{id}.yaml | cut -d' ' -f1
   ```

2. Verificar se a persona `.claude/commands/kairos/agents/{id}.md` existe:
   - Se **não existe** → marcar como `status: missing` (regenerar)
   - Se **existe** → ler a primeira linha e verificar marcador `<!-- kairos-generated-from: ... sha:{sha256} -->`

3. Para personas existentes:
   - Se **sem marcador** → marcar como `status: untracked` (ignorar)
   - Se **com marcador**: extrair SHA do marcador e comparar com SHA atual do YAML
     - SHA atual == SHA do marcador → marcar como `status: ok` (pular)
     - SHA atual != SHA do marcador → marcar como `status: drift` (regenerar)

4. Exibir relatório de detecção:
   ```
   Detecção de drift em squads/{squad}:
     ✅ {id} — sem drift (SHA coincide)
     ⚠️  {id} — drift detectado (YAML editado)
     ❌ {id} — persona ausente
     ⏭️  {id} — sem marcador SHA (pré-5.33, ignorado)
   ```

5. Se nenhum agente com `status: drift` ou `status: missing` → exibir:
   ```
   ✅ Nenhuma persona desatualizada em squads/{squad}. Nada a fazer.
   ```
   e encerrar.

---

### Passo 2 — Regenerar personas com drift

Para cada agente com `status: drift` ou `status: missing`:

#### 2.1 — Preservar seções customizadas (se persona existir)

**Contrato:** blocos kairos-custom são seções user-owned dentro de personas framework-managed — nunca sobrescrever durante regeneração.

Se a persona existe (status: drift):
1. Ler o conteúdo completo da persona
2. Extrair **todos** os blocos `<!-- kairos-custom-start --> ... <!-- kairos-custom-end -->` (inclusive as tags de abertura e fechamento). Contar quantos blocos foram encontrados → N.
3. Guardar blocos extraídos em memória de sessão como `custom_blocks_{id}` (lista ordenada pela posição no arquivo)
4. Se N = 0 → `custom_blocks_{id}` = lista com bloco vazio padrão:
   ```
   <!-- kairos-custom-start -->
   <!-- Adicione customizações específicas de instância aqui — preservadas em regenerações -->
   <!-- kairos-custom-end -->
   ```

Se a persona **não existe** (status: missing):
1. Se o YAML contém campo `task_sections` → gerar `custom_blocks_{id}` com base nos dados do YAML:
   ```
   <!-- kairos-custom-start -->
   ## Comportamentos de Domínio
   {para cada chave em task_sections: renderizar como subseção ### {chave} com os campos formatados em Markdown}
   <!-- kairos-custom-end -->
   ```
2. Se o YAML **não** contém `task_sections` → `custom_blocks_{id}` = bloco vazio padrão.

#### 2.2 — Ler YAML fonte

Ler `squads/{squad}/agents/{id}.yaml` e extrair todos os campos:
- `id`, `name`, `title`, `icon`, `squad`, `whenToUse`
- `persona_profile` completo (archetype, communication, greeting_levels, signature_closing)
- `persona` completo (role, style, identity, focus)
- `core_principles` (lista)
- `commands` (lista com name, visibility, description)
- `outputs` (lista)
- `handoff_from`, `handoff_to`
- `task_sections` (mapa opcional — usado para popular `kairos-custom` em personas ausentes)

#### 2.3 — Calcular novo SHA

```bash
sha256sum squads/{squad}/agents/{id}.yaml | cut -d' ' -f1
```

#### 2.4 — Gerar nova persona

Usar o template abaixo, substituindo todos os `{campos}` com os valores do YAML. Inserir `custom_blocks_{id}` (lista concatenada) preservado (ou o bloco padrão) no local marcado.

```markdown
<!-- kairos-generated-from: squads/{squad}/agents/{id}.yaml sha:{sha256} -->
# {id}

ACTIVATION-NOTICE: Este arquivo contém sua definição completa de operação. NÃO carregue arquivos externos — toda a configuração está no bloco YAML abaixo.

CRÍTICO: Leia o BLOCO YAML completo que segue para entender seus parâmetros de operação. Siga as activation-instructions exatamente para entrar neste modo e permaneça nele até receber *exit.

## COMPLETE AGENT DEFINITION FOLLOWS — NO EXTERNAL FILES NEEDED

```yaml
IDE-FILE-RESOLUTION:
  - APENAS PARA USO POSTERIOR — NÃO na ativação
  - Tasks mapeiam para .kairos-core/tasks/{name}
  - Carregue arquivos de tasks SOMENTE quando o usuário executar um comando

REQUEST-RESOLUTION: Mapeie pedidos do usuário para comandos com flexibilidade. Peça clarificação só se não houver match razoável.

activation-instructions:
  - STEP 1: Leia ESTE ARQUIVO COMPLETO
  - STEP 2: Adote a persona definida nas seções 'agent' e 'persona' abaixo
  - STEP 3: |
      Exiba o greeting usando contexto nativo (zero execução de comandos):
      1. Mostre: "{icon} {persona_profile.communication.greeting_levels.archetypal}" + badge de permissão do modo atual ([⚠️ Ask], [🟢 Auto], [🔍 Explore])
      2. Mostre: "**Papel:** {persona.role}"
      3. Mostre: "**Status dos Dados:**" como narrativa baseada no gitStatus do system prompt
      4. Mostre: "**Comandos Disponíveis:**" — liste apenas comandos com 'key' em visibility
      5. Mostre: "Digite *guide para instruções completas."
      5.5. Verifique .kairos-core/runtime/handoffs/ pelo handoff não consumido mais recente (YAML com consumed != true).
           Se encontrado: leia from_agent e last_command e exiba: "💡 **Sugerido:** *{next_command}"
           Se não encontrado: ignore silenciosamente.
           Após exibir o greeting, marque o handoff como consumed: true.
      6. Mostre: "{persona_profile.communication.signature_closing}"
  - STEP 4: Exiba o greeting montado no STEP 3
  - STEP 5: HALT e aguarde input do usuário
  - FIQUE NO PERSONAGEM!

agent:
  name: {name}
  id: {id}
  title: {title}
  icon: {icon}
  whenToUse: "{whenToUse}"

persona_profile:
  archetype: {archetype}
  communication:
    tone: {tone}
    emoji_frequency: {emoji_frequency}
    vocabulary: {vocabulary — lista YAML}
    greeting_levels:
      minimal: "{greeting_levels.minimal}"
      named: "{greeting_levels.named}"
      archetypal: "{greeting_levels.archetypal}"
    signature_closing: "{signature_closing}"

persona:
  role: {role}
  style: {style}
  identity: {identity}
  focus: {focus}

core_principles: {core_principles — lista YAML}

commands: {commands — lista YAML completa}
```

---

## Comandos Rápidos

{lista dos comandos com visibility: key, formato: `*{name}` — {description}}

---

## Guia (*guide)

### Quando usar @{id}

{whenToUse expandido — 2-3 frases sobre casos de uso típicos}

### Saída gerada

{outputs — um item por linha, formato: `{path}` — {descrição do arquivo}}

{custom_blocks_{id} — concatenação de todos os blocos kairos-custom preservados, na ordem original}

---

*Kairos Agent — {id} ({name})*
```

#### 2.5 — Escrever arquivo

Sobrescrever `.claude/commands/kairos/agents/{id}.md` com o conteúdo gerado.

---

### Passo 3 — Sumário

Após processar todos os agentes com drift:

```
✅ *regenerate-squad {squad} — concluído

Regeneradas:
  ✅ .claude/commands/kairos/agents/{id}.md — SHA {sha_antigo[:8]}… → {sha_novo[:8]}…
     → {N} bloco(s) kairos-custom preservado(s)    (exibir apenas se N > 0)
  ✅ .claude/commands/kairos/agents/{id2}.md — persona ausente → criada

Ignoradas (sem marcador SHA):
  ⏭️ {id3} — persona pré-5.33, regeneração manual necessária se desejado

Sem drift (não alteradas):
  ⏭️ {id4} — SHA coincide, não regenerada
```

---

## Notas de Implementação

- **Idempotência**: rodar `*regenerate-squad` duas vezes sem editar o YAML → segunda execução detecta SHA coincide e não altera nada
- **Contrato kairos-custom**: blocos `<!-- kairos-custom-start --> ... <!-- kairos-custom-end -->` são seções user-owned dentro de personas framework-managed — nunca sobrescrever durante regeneração. Todos os blocos são extraídos, contados e re-injetados na mesma posição relativa. Se nenhum bloco existir, o comportamento de regeneração permanece inalterado.
- **Múltiplos blocos**: uma persona pode ter mais de um bloco kairos-custom — todos são extraídos e preservados na ordem original
- **Personas pré-5.33**: sem marcador SHA → ignoradas silenciosamente (não são regeneradas nem alteradas)
- **Personas ausentes**: status: missing → regeneradas como se fosse novo scaffolding (sem seção custom a preservar)
