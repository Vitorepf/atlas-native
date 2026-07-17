---
doc_schema: atlas_native_canonical_pointer.v1
title: Atlas Native Codigo
status: active
owner: operator
source_of_truth: docs/atlas-codigo-evolucao.md
---

# Atlas Native Codigo

Doc curto do canto canonico. O dossie do dominio e
`atlas-codigo-evolucao.md`; OBRA.md vence quando houver conflito.

## Verdade atual

- Superficie no app para governanca de codigo: radar, grafo, proveniencia,
  sinais, cura e semana.
- Rotas publicas ficam em `AtlasRoute`: `/code/graph`, `/code/provenance`,
  `/code/violations`, `/code/heals`, `/code/repos`, `/code/ask`,
  `/code/mirror`, `/code/week`, `/code/why`.
- Schemas principais: `atlas.code.graph.v1`, `atlas.code.provenance.v2`,
  `atlas.code.violations.v1`, `atlas.code.heals.v1`, `atlas.code.repos.v2`,
  `atlas.code.ask.v1`, `atlas.code.mirror.v1`, `atlas.code.week.v1`,
  `atlas.code.why.v1`.

## Onde mexer

- DTOs/client: `Sources/AtlasCore/AtlasCode*.swift`.
- Checks: `Sources/AtlasCoreChecks/AtlasCode*Checks.swift`.
- Models/casca: `App/Atlas/AtlasCode*.swift`.

## Regras

Cor codifica estado, nao autor. Ausencia de trace/prova vira texto honesto, nao
numero ou badge inventado.

## Canto canonico

Indice: `canto-canonico.md`. Arquitetura: `arquitetura.md`. Irmaos:
`atlas-native-rich-input.md`, `atlas-native-autonomos.md`,
`atlas-native-gates.md`.
