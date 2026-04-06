Classifique as atividades empresariais dos leads que não têm cobertura de nicho.

## O que fazer

1. Busque os leads via webhook:
   ```bash
   curl -s https://n8n.vendoteca.com/webhook/kairos-leads
   ```

2. Identifique as atividades únicas entre leads com `Pode disparar = SIM` que NÃO contêm nenhuma das keywords abaixo:
   - saúde: odont, dent, clin, saude, medic, psico, terap, fisiot, nutri
   - beleza: estet, beleza, salao, cabel, barbear, manic, sobrancel, depil, maqui, spa
   - eventos: event, festa, fotograf, film, dj, decor, cerimonial, buffet, casament
   - educação: ensino, educ, escola, curso, idioma, trein, instrut, aula
   - manutenção: manut, mecanic, oficina, reparo, eletric, instal, limpeza, climat, assist
   - alimentação: restaur, lanch, bebid, bar, aliment, refeic, pizz, hamburg
   - construção: constr, obra, engenh, reform, arquitet, empreit
   - jurídico: advoc, jurid, direito

3. Para cada atividade sem cobertura, classifique em um dos nichos:
   `saude_clinicas | estetica_bem_estar | eventos_fotografia | educacao_cursos | manutencao_tecnica | restaurantes_alimentacao | construcao_engenharia | advocacia | outro`

4. Conte quantos leads cada atividade representa.

5. Salve o resultado em `data/reports/niche-map-YYYY-MM-DD.json`:
   ```json
   {
     "geradoEm": "...",
     "totalAtividades": N,
     "nichoMap": { "atividade": "nicho" },
     "contagemLeads": { "nicho": N }
   }
   ```

6. Exiba um resumo: quais nichos têm mais leads sem cobertura e recomende quais keywords adicionar ao workflow do n8n para capturá-los.
