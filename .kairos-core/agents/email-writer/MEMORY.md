# Email Writer Memory (Eva)

## Active Patterns

### Dados e Saída
- Emails gerados: `data/emails/emails-YYYY-MM-DD.json`
- Task de referência: `.kairos-core/tasks/write-emails.md`
- Handoffs salvos: `.kairos/handoffs/`

### Domínios Suspeitos Identificados
<!-- Preencher com padrões reais encontrados -->
- Domínios de contabilidade/consultoria para empresas de beleza/saúde
- Emails com "financeiro@", "admin@" em empresas MEI sem estrutura administrativa
- Domínio completamente diferente do nome fantasia sem explicação óbvia

### Padrões de Qualidade Validados
<!-- Padrões de abertura que funcionaram bem — preencher após feedback -->
- Barbearia: abertura pela perspectiva do cliente que não volta
- Salão: abertura pelo volume de perguntas no WhatsApp
- Clínica estética médica: abertura pelo tempo perdido em triagem

### Anti-padrões Identificados em Produção
- "Negócio em Cidade: proposta" — bloqueado
- Abertura "Oi, [nome]! + pitch imediato" — bloqueado
- Mais de um travessão por e-mail — bloqueado
- CTA idêntica em todos os e-mails do batch — bloqueado
- Descrição técnica do serviço no primeiro parágrafo — bloqueado

### Perfis por Capital Social
- R$1k–5k: tom de MEI, linguagem simples, reconhece limitação de tempo
- R$5k–50k: pequeno negócio crescendo, alguma estrutura
- R$50k–100k: negócio estabelecido, pode ter funcionários
- R$100k+: empresa madura, foco em escala e eficiência

## Promotion Candidates
<!-- Padrões que deveriam ir para .claude/rules/ -->

## Archived
