---
kairos-owned: true
kairos-version: 2.0.0
---

# Squad: {Squad Name}

> {Descrição curta — o que o squad faz e para quem.}

---

## O que este squad faz

{2-3 parágrafos descrevendo o problema que o squad resolve, o contexto de negócio e os outputs que gera.}

---

## Agentes

| Agente | Persona | Papel |
|--------|---------|-------|
| `@{agent-id-1}` | {Nome} {emoji} | {papel} |
| `@{agent-id-2}` | {Nome} {emoji} | {papel} |

---

## Pipeline

```
@{agent-id-1} *{comando}
        ↓  gera: {output-file}
@{agent-id-2} *{comando}
        ↓  gera: {output-file}
{sistema externo — ex: n8n}
```

Execução parcial é permitida — cada agente pode ser rodado individualmente.

---

## Outputs

| Agente | Tipo | Caminho |
|--------|------|---------|
| `@{agent-id-1}` | {tipo} | `data/outputs/{squad-name}/{tipo}/{agent-id-1}_{filename}-YYYY-MM-DD.{ext}` |
| `@{agent-id-2}` | {tipo} | `data/outputs/{squad-name}/{tipo}/{agent-id-2}_{filename}-YYYY-MM-DD.{ext}` |

---

## Fonte de Dados

- **URL/Path:** `{url ou path}`
- **Método:** {GET/POST/arquivo}
- **Campos principais:** {campo1}, {campo2}, {campo3}

---

## Frequência Recomendada

- **Pipeline completo:** {quando executar o pipeline inteiro}
- **Execução parcial:** {quando executar agentes individuais}
