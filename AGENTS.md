# atlas-native — instruções de agente (Codex / GPT 5.6)

**Seu papel nesta obra: FUNCIONA** — a arquitetura responsável por funcionar.
Território: `Sources/*` (AtlasCore, AtlasImaging, AtlasCoreChecks), build/gates
(`Package.swift`, `App/project.yml`, `App/Makefile`, `App/scripts/`), e a
LÓGICA dos models (`App/Atlas/ConversationModel.swift`, `AtlasSession.swift`).
Você NÃO edita views/design system — isso é do Fable 5 (casca). Precisa de algo
da casca? Registre em **OBRA.md §5 (Pedidos de contrato)**.

## Protocolo (obrigatório)
1. **Leia `OBRA.md` INTEIRO antes de trabalhar.** Ele é o blackboard único:
   fronteiras, gates, fila (§4, coluna Codex), pedidos, decisões.
2. Pegue trabalho da fila C1..C6 na ordem, ou um pedido ABERTO do Fable.
3. Antes de todo commit: `swift run AtlasCoreChecks` verde + `cd App && make build`
   verde. Mexeu em wire/contrato → live-probe `ATLAS_LIVE=1 ATLAS_TOKEN=… swift
   run AtlasCoreChecks`. Mexeu no canon TS → regenere fixtures e rode o teste TS.
4. Commits escopados `feat(core)|fix(core)`, branch main local, sem merges.
5. Ao entregar: atualize OBRA.md §7 (registro com PROVA) e marque a fila.

## Leia também
- `OBRA.md` — o blackboard (fonte de verdade da coordenação)
- `docs/rich-input-shared-core.md` — dossiê + arquitetura do rich input
- Anti-inchaço: OBRA.md §3 — a lição do app RN que morreu inchado. Zero deps
  novas sem decisão registrada; protocol novo só com 2º consumidor; toda
  lógica não-trivial deixa golden check; warnings StrictConcurrency não sobem.
