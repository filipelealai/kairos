# Templates de Onboarding

Cada arquivo neste diretório é um módulo de seção do kit de onboarding.
O @onboarding-writer seleciona e personaliza seções ao perfil do cliente e tipo de projeto.

## Seções Canônicas (a implementar na story)

| Arquivo | Seção | Obrigatório |
|---------|-------|-------------|
| `01-boas-vindas.md` | Mensagem de boas-vindas personalizada | Sim |
| `02-proximos-passos.md` | O que o cliente deve fazer agora (checklist) | Sim |
| `03-acessos-necessarios.md` | O que o cliente deve nos enviar (acessos, credenciais, materiais) | Sim |
| `04-cronograma.md` | Cronograma inicial do projeto | Recomendado |
| `05-contatos.md` | Quem contatar e como (canais de comunicação) | Sim |
| `06-expectativas.md` | O que esperar nas primeiras semanas | Recomendado |
| `07-faq.md` | Perguntas frequentes do início de projeto | Opcional |

## Como Personalizar por Tipo de Projeto

Para criar variante por tipo de projeto (ex: onboarding para desenvolvimento vs. consultoria):
- Criar subdiretório `onboarding/desenvolvimento/` ou `onboarding/consultoria/`
- Adaptar seções com terminologia e etapas específicas

A base permanece estável — variantes são aditivas.
