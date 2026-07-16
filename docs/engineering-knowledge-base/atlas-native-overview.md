---
doc_schema: atlas_canonical_module_doc.v1
id: atlas-native-overview
type: engineering_knowledge
title: Atlas Native — visão canônica do app iOS
status: active
implementation_state: shipping_conversation_supremacy_and_codigo
owner: operator (Vitor)
priority: 90
category: native
summary: >-
  Entrada canônica do repositório atlas-native para a rede documentacional do
  Atlas. O app iOS é a CASCA do ecossistema: a inteligência mora no
  atlas-server; o app entrega experiência. Dois pilares: Atlas AI (conversa
  com execução agêntica viva, presença em Lock Screen/Dynamic Island, fila,
  review) e Atlas Código (grafo governado, proveniência, radar, cura 24/7).
  Este doc aponta para as fontes de verdade internas do repo.
when_to_use:
  - Qualquer IA/sessão abrindo o workspace atlas-native pela primeira vez
  - Antes de implementar qualquer feature no app iOS
  - Para resolver onde mora um domínio (engine vs models vs casca)
trigger_signals:
  - atlas-native
  - app iOS
  - SwiftUI casca
  - AtlasCore
tags: [ios, swiftui, swift6, casca, atlas-ai, atlas-codigo]
repo_paths:
  - Sources/AtlasCore
  - Sources/AtlasImaging
  - Sources/AtlasCoreChecks
  - App/Atlas
  - App/Widgets
related_paths:
  - OBRA.md
  - docs/rich-input-shared-core.md
  - docs/atlas-codigo-evolucao.md
  - docs/plano-sota-10-de-10.md
  - docs/spec-proximo-patamar.md
  - docs/roadmap-proximo-patamar.md
depends_on:
  - atlas-cognition-operating-system
  - atlas-ai-knowledge-governance-system
forbidden_changes:
  - Rede/JSON/storage na casca (boundary check falha o gate)
  - Dependência externa sem decisão registrada em OBRA.md §6
  - Tela/rota nova sem decisão do operador (era atual: zero telas novas)
quality_gates:
  - swift run AtlasCoreChecks (exit 0)
  - cd App && make build (exit 0)
  - XCUITest AtlasCodeFlowTests para fluxos visuais
evidence:
  - docs/evidence/
---

# Atlas Native — visão canônica

## O que é

App iOS nativo (iPhone-only, iOS 17+, Swift 6 strict concurrency, ZERO
dependências externas) que serve de **casca fina** para o atlas-server. Regra
ontológica: a inteligência mora no servidor; o app projeta contratos
versionados provider-safe (`atlas.*.v1`) e nunca inventa dado.

## Fonte de verdade da coordenação

**`OBRA.md` (raiz)** é o blackboard único da obra: fronteiras de propriedade
(§1), gates (§2), constituição anti-inchaço (§3 — a lição do app RN que
morreu inchado), fila de trabalho (§4), pedidos de contrato entre lanes (§5),
decisões do operador (§6), registro append-only com prova (§7). Toda IA lê o
OBRA.md INTEIRO antes de trabalhar.

## Arquitetura em três camadas

| Camada | Onde | Regra |
|---|---|---|
| Engine | `Sources/AtlasCore` (+ `AtlasImaging`) | Foundation-only; actors; DTOs fail-closed; redaction provider-safe |
| Models | `App/Atlas/*Model*.swift`, `AtlasSession` | `@MainActor @Observable`; único lugar da casca que fala com o `AtlasClient` |
| Casca | `App/Atlas/*View*` + design system | Renderiza SÓ o que o model expõe; zero rede/JSON/storage (boundary check) |

O seam casca⇄engine são os models @Observable + structs públicas do Core
(presença tipada, planos, atividades, reviews, Autônomos, Código).

## Qualidade

`Sources/AtlasCoreChecks` é um executável de golden checks (sai exit 1 em
falha; inclui boundary checks que varrem o código-fonte da casca e live-probes
opt-in com `ATLAS_LIVE=1`). Gates antes de todo commit: checks + `make build`,
sem `|| true`. Prova visual = simulador + iPhone físico + screenshots em
`docs/evidence/`.

## Dossiês canônicos internos

- `docs/rich-input-shared-core.md` — contrato e engine de anexos (chunk 1.5MB,
  resume, SHA-256 fim-a-fim).
- `docs/atlas-codigo-evolucao.md` — o domínio Atlas Código (11 leis, fases
  E1–E5, horizontes H1–H12, anel nativo N1–N8).
- `docs/plano-sota-10-de-10.md` — transformação de qualidade executada (poda,
  tipos, hot path, splits).
- `docs/spec-proximo-patamar.md` + `docs/roadmap-proximo-patamar.md` — as 5
  verticais da era atual (zero telas novas) e o roadmap decidido pelo operador.
