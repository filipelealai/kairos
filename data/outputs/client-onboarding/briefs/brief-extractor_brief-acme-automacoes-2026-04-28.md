# Brief — Acme Automações

**Data:** 2026-04-28
**Extraído por:** @brief-extractor (Brix)
**Versão:** 1.0 — dados mock para validação de pipeline end-to-end (Story 4.3)

---

## Identificação

- **Empresa:** Acme Automações Ltda
- **Setor:** Manufatura / Indústria leve
- **Porte:** Pequena (50 funcionários)
- **Contato principal:** Carla Mendes — Gerente de Operações

## Contexto do Problema

**Dores:**
1. Processo de cotação com fornecedores 100% manual — planilhas Excel sem integração
2. Aprovações de compra demoram 3–5 dias úteis por e-mail e WhatsApp
3. Falta de visibilidade do histórico de compras e preços praticados

**Situação atual:**
Equipe de compras usa planilhas compartilhadas e e-mail para cotações. Cada cotação exige
contato manual com 3–5 fornecedores e consolidação manual de respostas. Aprovações são feitas
informalmente no WhatsApp com o diretor.

**Tentativas anteriores:**
Tentaram usar um ERP (TOTVS) mas o módulo de compras foi considerado complexo demais para
a equipe. Módulo nunca foi configurado e ficou sem uso.

## Objetivo do Projeto

**Objetivos:**
1. Automatizar o processo de cotação com envio e consolidação de respostas
2. Criar fluxo de aprovação formalizado com registro e rastreabilidade
3. Ter histórico centralizado de fornecedores, preços e pedidos

**Critérios de sucesso:**
- Reduzir tempo médio de cotação de 5 dias para 1 dia útil
- Todas as aprovações com registro rastreável (quem aprovou, quando, qual valor)

**Prioridade de negócio:** Alta — diretor quer implementação no próximo trimestre

## Escopo

**Escopo esperado:**
1. Módulo de cotação: formulário digital, envio automático para fornecedores cadastrados, consolidação de respostas
2. Fluxo de aprovação digital com notificação e registro de aprovação
3. Painel de histórico de compras e fornecedores
4. Integração com e-mail (Gmail/Outlook) para envio das cotações

**Fora do escopo:**
- Integração com o ERP TOTVS existente
- App mobile para aprovações (apenas web)
- Gestão de estoque

**Integrações:** Gmail (envio de cotações), sem outras integrações obrigatórias

## Restrições

- **Orçamento:** R$ 15.000 – R$ 25.000 [declarado pelo cliente]
- **Prazo esperado:** 10–12 semanas
- **Restrições técnicas:** Equipe sem perfil técnico interno — solução deve ser low-code ou com interface simples de administrar
- **Restrições legais:** Nenhuma declarada

## Stakeholders

- **Decisor:** Roberto Alves — Diretor Geral
- **Stakeholders:** Carla Mendes (operações), Marcos Souza (financeiro)
- **Equipe cliente:** Carla Mendes será o ponto de contato principal no projeto

## Contexto Técnico

- **Stack atual:** Google Workspace (Gmail, Drive, Sheets), sem ERP ativo em uso
- **Nível técnico interno:** Baixo — usuários avançados de planilha, sem dev interno
- **Dados disponíveis:** Lista de fornecedores em planilha Google Sheets (compartilhável)

---

## Campos para Elicitação

Nenhum — brief completo com todos os campos críticos preenchidos.

---

*Gerado por @brief-extractor — base para proposta, contrato e onboarding*
*Mock para validação de pipeline end-to-end — Story 4.3*
