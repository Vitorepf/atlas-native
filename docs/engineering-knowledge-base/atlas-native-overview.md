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
risk_level: medium
graph_id: atlas-native-overview
graph_title: Atlas Native (app iOS)
graph_world: atlas
graph_layer: system
graph_kind: surface
graph_parent: atlas-documentation-network
graph_status: active
graph_source: repo
human_name: Atlas Nativo (iPhone)
human_summary: O app iOS é a casca do Atlas — a inteligência mora no atlas-server; o app entrega conversa agêntica viva, presença na tela bloqueada, governança de código e a frota 24/7.
human_what: Entrada canônica do repositório atlas-native para a rede documentacional.
human_purpose: Qualquer IA/sessão abrindo este workspace entende o que é o app, onde mora cada camada e quais gates valem, sem depender de memória de chat.
human_input: OBRA.md, dossiês em docs/, código em Sources/ e App/.
human_output: Orientação de arquitetura, fronteiras, gates e ponteiros para as fontes de verdade.
human_change_when: Mexa quando mudar arquitetura de camadas, gates ou pilares de produto do app.
human_block_when: Bloqueie se este doc contradisser OBRA.md — o blackboard vence.
canonical_name: Atlas Native Overview
technical_name: AtlasCore
summary: >-
  Entrada canônica do atlas-native na rede documentacional do Atlas. App iOS
  nativo (iPhone-only, Swift 6 strict, zero dependências externas) que serve
  de casca fina ao atlas-server. Dois pilares: Atlas AI (conversa com execução
  agêntica viva, presença, fila, review) e Atlas Código (grafo governado,
  proveniência, radar, cura 24/7).
when_to_use:
  - Qualquer IA/sessão abrindo o workspace atlas-native pela primeira vez
  - Antes de implementar qualquer feature no app iOS
  - Para resolver onde mora um domínio (engine vs models vs casca)
trigger_signals: [atlas-native, app iOS, SwiftUI casca, AtlasCore]
tags: [ios, swiftui, swift6, casca, atlas-ai, atlas-codigo]
capabilities:
  - conversa_agentica_com_execucao_viva
  - presenca_lock_screen_dynamic_island
  - atlas_codigo_grafo_governado
  - autonomos_command_surface
decisions:
  - O app é casca fina; a inteligência mora no atlas-server (OBRA.md §0).
  - Zero dependências externas; zero telas novas na era atual (decisão do operador 2026-07-16).
  - Cor codifica estado, nunca autor; ausência de dado é ausência na tela.
  - Voice Supremacy removida do roadmap (futuro distante).
maintenance:
  - Atualizar quando OBRA.md §6 registrar decisão de arquitetura/pilar.
  - Manter os ponteiros de dossiês válidos após reorganizações de docs/.
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
  - atlas-documentation-network
  - atlas-cognition-operating-system
flows_to:
  - atlas-documentation-network
unlocks:
  - sessões de IA orientadas no workspace atlas-native sem memória de chat
governs:
  - a entrada documental canônica do repositório atlas-native
allowed_changes:
  - Atualizar ponteiros e estado dos pilares conforme OBRA.md evoluir
forbidden_changes:
  - Rede/JSON/storage na casca (boundary check falha o gate)
  - Dependência externa sem decisão registrada em OBRA.md §6
  - Tela/rota nova sem decisão do operador (era atual, zero telas novas)
evidence:
  - docs/evidence/ (screenshots datados por entrega)
  - OBRA.md §7 (registro append-only com prova)
required_tests:
  - swift run AtlasCoreChecks (exit 0)
  - cd App && make build (exit 0)
quality_gates:
  - checks + build antes de todo commit, sem exceção
  - XCUITest AtlasCodeFlowTests para fluxos visuais
failure_modes:
  - Doc desatualizado vs OBRA.md → OBRA vence; atualizar este doc
next_actions:
  - Ampliar o canto com um doc canônico por domínio (rich input, código, autônomos)
observability_signals:
  - contagem de golden checks impressa pelo AtlasCoreChecks
requires_evidence: true
---

# Atlas Native — visão canônica

## Resumo

App iOS nativo (iPhone-only, iOS 17+, Swift 6 strict concurrency, zero
dependências externas) que serve de **casca fina** ao atlas-server. Regra
ontológica: a inteligência mora no servidor; o app projeta contratos
versionados provider-safe (`atlas.*.v1`) e nunca inventa dado.

## Papel no Atlas

É a superfície móvel do operador: intenção, regência de execução, prova,
governança de código e frota 24/7 — no bolso e na tela bloqueada.

## Onde Se Encaixa

Membro da Rede Documentacional (`atlas-documentation-network`); consome o
atlas-server via contratos versionados; coordenação multi-IA pelo OBRA.md.

## Fluxo

Intenção (conversa/pílula) → execução viva (presença, plano, timeline) →
prova (recibo, diff, quality) → governança (grafo, lei, cura) → frota
(Autônomos 24/7). A conversa é o drill-down; a home se reorganiza em cockpit
quando há trabalho vivo.

## Contratos

Três camadas: **AtlasCore** (engine Foundation-only; actors; DTOs
fail-closed; redaction provider-safe) → **models @Observable** (único lugar
da casca que fala com o `AtlasClient`) → **casca SwiftUI** (renderiza só o
que o model expõe; zero rede/JSON/storage — o boundary check varre e falha o
gate). O seam são os models + structs públicas do Core.

## Dependencias

atlas-server (OrbStack :3737) para todo dado; design system próprio
(slate teal + gold + Fraunces); XcodeGen para o projeto.

## Escopo de Implementacao

Fonte de verdade da coordenação: **OBRA.md** (fronteiras §1, gates §2,
constituição anti-inchaço §3, fila §4, pedidos §5, decisões §6, registro §7).
Era atual: SOTA 10/10 concluído; 5 verticais do Próximo Patamar em execução
(`docs/spec-proximo-patamar.md`).

## Evidencias

`docs/evidence/` (screenshots datados) e OBRA.md §7 (registro append-only
com prova por entrega). Gates: `swift run AtlasCoreChecks` + `make build`.

## Exemplos

Dossiês canônicos internos: `docs/rich-input-shared-core.md` (anexos,
chunk 1.5MB, SHA-256 fim-a-fim), `docs/atlas-codigo-evolucao.md` (domínio
Código: 11 leis, E1–E5, H1–H12, N1–N8).

## Regras para IA

Ler OBRA.md INTEIRO antes de trabalhar; gates antes de todo commit; branch
main local apenas; zero dado inventado; ausência ≠ zero; nenhum botão sem
ação real; `device-pending` nunca vira prova.

## Riscos

Doc desatualizado vs OBRA.md (o blackboard vence); casca ganhando efeitos
colaterais (o boundary check é a defesa executável).

## Proximas Acoes

Ampliar o canto com um doc canônico por domínio quando a F2 da rede
(ingestão federada) estiver entregue no atlas-server.
