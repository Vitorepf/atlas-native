---
doc_schema: atlas_native_canonical_corner.v1
title: Canto canonico do atlas-native
status: active
owner: operator
source_of_truth: OBRA.md
---

# Canto canonico do atlas-native

Este e o indice curto do app nativo. Ele aponta para as fontes vivas; nao
substitui OBRA.md, nem os dossies longos.

## Leitura em ordem

1. `../OBRA.md` — blackboard: fronteiras, gates, fila, pedidos, decisoes e prova.
2. `arquitetura.md` — mapa de camadas, seams, contratos `atlas.*` e checks.
3. `atlas-native-gates.md` — comandos obrigatorios e quando usar `make verify`.
4. `atlas-native-rich-input.md` — ponte para o canon de anexos/upload.
5. `atlas-native-codigo.md` — ponte para Atlas Codigo no app.
6. `atlas-native-autonomos.md` — ponte para a area Autonomos 24/7.

## Fontes longas

- `rich-input-shared-core.md`
- `atlas-codigo-evolucao.md`
- `engineering-knowledge-base/atlas-native-overview.md`
- Planos/specs em `docs/` continuam contexto, nao fila executavel. A fila viva
  e sempre OBRA.md.

## Regra de manutencao

Quando uma decisao em OBRA.md §6 muda arquitetura, gates ou superficie, atualize
este indice e o doc curto afetado no mesmo commit de documentacao.
