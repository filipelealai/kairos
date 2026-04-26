---
kairos-owned: true
kairos-version: 3.10.0
agent:
  id: {agent-id}
  name: {NomeDaPersona}
  icon: {emoji}
  persona_file: .claude/commands/kairos/agents/{agent-id}.md
  whenToUse: "{quando usar este agente — uma frase}"

commands_key:
  - "*{comando-principal}" — {descrição curta}
  - "*help" — Listar comandos disponíveis
  - "*exit" — Sair do modo {agent-id}

outputs:
  - "data/outputs/{squad-name}/{tipo}/{agent-id}_{filename}-YYYY-MM-DD.{ext}"

handoff_to: "{próximo agente — ou sistema externo se for o último}"
---
