# Niche Classifier Memory (Nix)

## Active Patterns

### Dados e Saída
- Niche map: `data/outputs/cold-prospecting/reports/niche-classifier_niche-map-YYYY-MM-DD.json`
- Script TypeScript: `src/agents/niche-classifier.ts`
- Usa Claude API em lotes de 30 atividades por chamada

### Nichos Disponíveis
`saude_clinicas | estetica_bem_estar | eventos_fotografia | educacao_cursos | manutencao_tecnica | restaurantes_alimentacao | construcao_engenharia | advocacia | outro`

### Keywords de Cobertura Atual
- saude: odont, dent, clin, saude, medic, psico, terap, fisiot, nutri
- beleza: estet, beleza, salao, cabel, barbear, manic, sobrancel, depil, maqui, spa
- eventos: event, festa, fotograf, film, dj, decor, cerimonial, buffet, casament
- educacao: ensino, educ, escola, curso, idioma, trein, instrut, aula
- manutencao: manut, mecanic, oficina, reparo, eletric, instal, limpeza, climat, assist
- alimentacao: restaur, lanch, bebid, bar, aliment, refeic, pizz, hamburg
- construcao: constr, obra, engenh, reform, arquitet, empreit
- juridico: advoc, jurid, direito

### Gotchas Técnicos
- Script processa atividades em lotes de 30 — atividades idênticas contam como 1 (deduplicadas antes do envio à API)
- `Atividade Principal` pode ter pequenas variações de texto para o mesmo negócio — o Claude normaliza, mas vale revisar o mapa gerado
- Se porcentagem de nichos `outro` > 30%: sugerir novas keywords para o workflow do n8n (via `@kairos *new-story` se for mudança estrutural)
- Reclassificar após adicionar keywords novas ao n8n — o mapa anterior pode estar desatualizado
- Output JSON é sobrescrito por data — histórico de classificações não é preservado automaticamente

### Recomendações Anteriores
<!-- Preencher após execuções reais com keywords sugeridas e resultado -->

## Promotion Candidates
<!-- Keywords validadas que devem ir para o workflow do n8n -->

## Archived
