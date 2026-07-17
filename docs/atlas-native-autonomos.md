---
doc_schema: atlas_native_canonical_pointer.v1
title: Atlas Native Autonomos
status: active
owner: operator
source_of_truth: OBRA.md
---

# Atlas Native Autonomos

Doc curto do canto canonico. Autonomos e uma area propria 24/7; nao e card de
conversa nem sessao comum.

## Verdade atual

- Fonte no app: `AutonomosModel` + `AutonomosView`.
- Rotas principais em `AtlasRoute`: `/ai/software-company-stewardship/loop/*`,
  `/ai/software-company-stewardship/autonomos/digest`, `/agents/status`,
  `/agents/history`, `/agents/task-health`.
- A casca usa somente campos publicos do Core: areas, lock, ciclos, backlog,
  entregas comprovadas, frota, historico, saude e digest quando publicados.
- Entrega comprovada exige `outcome=merged`, `merge_performed=true` e
  `merge_hash`; plano, backlog ou tentativa nao viram entrega.

## Onde mexer

- Contratos/DTOs: `Sources/AtlasCore/AtlasAutonomos.swift`.
- Checks: `Sources/AtlasCoreChecks/AtlasAutonomosChecks.swift`.
- Estado/casca: `App/Atlas/AutonomosModel.swift` e
  `App/Atlas/AutonomosView.swift`.

## Regras

Nao expor prompt, path interno, stdout, workcell ou JSON cru. Ausencia de host,
branch, digest ou progresso permanece ausencia.

## Canto canonico

Indice: `canto-canonico.md`. Arquitetura: `arquitetura.md`. Irmaos:
`atlas-native-rich-input.md`, `atlas-native-codigo.md`,
`atlas-native-gates.md`.
