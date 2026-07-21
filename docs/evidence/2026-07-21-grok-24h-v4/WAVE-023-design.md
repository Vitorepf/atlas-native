# WAVE-023 — execution-presence-one-voice

**Status:** design · proposed  
**Wave:** `WAVE-023-execution-presence-one-voice`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual · W0 council ≥3 explore)  
**Δ patamar:** **max**  
**Rank:** 1 (regen mechanical)

---

## Problema

WAVEs **018** (Island/Lock glance) e **022** (ribbon face) fecharam **pedaços**
do órgão de presença. O operador ainda **reaprende a fase** em três vozes:

1. **Glance** (`AtlasTurnGlanceFace`) — finished · multiSession · paused · running  
2. **Ribbon** (`ConversationExecutionFace`) — finished · reconnect · paused ·
   multiAgent · running · quiet  
3. **Attention in-app** — `ExecutionStateCard` (~646 LOC, peels internos) +
   `ExecutingStrip` em `ConversationCockpitBody` ainda rebrancham em
   `showsReconnectSurface` / progress / activity **sem** consumir a face  
4. **LiveNow** (hub VIVO AGORA) — `LiveNowRow` / section com timing e phaseTitle
   **locais**, sem o vocabulário falado da face

Produto: julgar o run **dentro e fora** do app em ~3s com **uma** gramática.
Hoje Island fala “paused”, ribbon fala “em pausa”, card fala kicker próprio,
LiveNow fala phaseTitle cru. Continuity App Group / widgets accessories
permanecem **BLOCKED** — esta onda **não** restaura snapshot; só unifica a
voz de **presença de execução** já viva.

Council 2026-07-21 (Code · Conversa · Arena/Continuity · OBRA): conversa max
cycle write→fly→read→judge **fechado**; residual max casca-unblocked = este
órgão incompleto (não peels de markdown, não App Group theater).

---

## Patamar

| Antes | Depois |
|---|---|
| 018 glance + 022 ribbon only | **StateCard + strip + LiveNow** na mesma face machine |
| Strip bool soup reconnect | Strip branches on `ConversationExecutionFace` |
| StateCard dialect / ~60 peels | Exclusive faces + attention overlays; fuse |
| LiveNow spoken paralelo | Spoken ≡ face vocabulary (onde o signal existe) |
| Timer 0:00 residual | Honesty parity glance (“—” / silence, never false 0:00) |

Δ = **Continuity + Conversa agêntica** no mesmo órgão de presença (capacidade
de julgar o run em qualquer superfície de atenção).

---

## Arquitetura

### Princípios

- **Casca only.** Zero novo DTO Core; presentation from `ChatBubble`,
  `executionPresentationState`, `LiveSessionSnapshot`, ContentState.
- **One face vocabulary (product words):**  
  `finished | reconnect | paused | multi | running | quiet`  
  Adapters:
  - ContentState → keep `AtlasTurnGlanceFace` (018) — map multiSession↔multi
  - ChatBubble → `ConversationExecutionFace` (022) — extend consumers
  - PresentationState → StateCard exclusive chrome + attention overlays
  - LiveSessionSnapshot → LiveNow spoken/timer honesty
- **Priority (in-app, 022):**  
  finished → reconnect → paused → multiAgent → running → quiet
- **Attention overlays** (não faces): awaiting · recovering · replanning ·
  failed · decision — exclusive kickers from model fields only; never invent.
- **WAVE-012 dual-surface pétreo:** streaming+reconnect → strip primary;
  ribbon silences reconnect primary copy (`ribbonShowsReconnectBanner`).
- **Timer honesty:** missing ms / finished → silence or “—”, never false
  `0:00` (parity 018 `showsGlanceTimer`).
- Hosts ≤400; StateCard fuse target structural sections not god-concat.

### Árvore alvo

```
PresenceFace adapters
├── Glance (018)          Island / Lock          ContentState
├── Ribbon (022)          ExecutionRibbon        ConversationExecutionFace
├── Strip                 ExecutingStrip         SAME face + dual-surface
├── Attention             ExecutionStateCard     face + attention overlays
└── Hub                   LiveNowRow/Section     spoken/timer ≡ face words
```

### Fora de escopo (pétreo)

- App Group entitlements / snapshot writer “restore” / WidgetCenter claims.
- Fleet / CodeWeek / LockAccessory **data** restore (idle fuse later only).
- Arena dedicated Live Activity.
- Re-chrome pill (016) / pack grammar (020).
- Core execution DTO / C14 field invention.
- NL mandar-fazer theater.
- Nova área / tab / god-file ConversationView collapse.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `ConversationExecutionPhase.swift` | Shared helpers: strip face branch, timer honesty, spoken map export; optional LiveNow adapter |
| `ConversationCockpitBody.swift` (`ExecutingStrip`) | Branch + a11y from face, not raw reconnect bool soup |
| `ExecutionStateCard.swift` | Consume faces + attention overlays; structural fuse |
| `ExecutionRibbon.swift` | Keep 022; only glue if helpers move |
| `LiveNowRow.swift` / `LiveNowSection.swift` | Spoken/timing vocabulary align when signal maps |
| `AtlasTurnGlanceGrammar.swift` | **Read-only align** if spoken words need shared table (no redesign Island) |
| Optional: notification spoken map | Same labels if already presentation-only |

### W3

| Alvo | Estimativa |
|---|---|
| StateCard internal peel collapse | **−250…−600** |
| Strip/LiveNow glue | **−50…−150** |

`WAVE-023-compress.md` after land.

---

## DoD (≥5)

1. **`ExecutingStrip` branches on `ConversationExecutionFace`** (not ad-hoc
   `showsReconnectSurface` soup alone); spoken ≡ face.
2. **`ExecutionStateCard` exclusive chrome** driven by face + attention
   overlay enum; no parallel terminal/live kickers inventados.
3. **LiveNow** phase/timing spoken uses the **same face words** as ribbon
   where the signal exists (running / paused / finished / multi).
4. **Timer honesty** on StateCard + LiveNow: never false `0:00` when ms
   missing or finished (parity glance).
5. **WAVE-012 dual-surface** preserved: streaming+reconnect → strip primary;
   ribbon silence reconnect primary.
6. **Finished** silences reconnect/watchdog noise (already 022 ribbon —
   StateCard/strip match).
7. A11y spoken ≡ visual face; A11yIDs stable; gates
   `swift run AtlasCoreChecks` + `cd App && make build`.
8. **Zero** claim App Group / widget data restore “done”.

---

## Anti-objetivos

- App Group portal work disguised as Continuity.
- Widget accessory peel fuse as rank-1 (craft, low Δ while data blocked).
- Reabrir 016 pill chrome or 021 Arena scoreboard.
- Inventar Core status / tool write.
- Opacity ladder / micro-copy wave without face DoD.
- God-file collapse of ConversationSurface / ConversationView.
- Second face enum without adapter table (prefer extend 022 + map 018).

---

## Plano W3 (Implementer)

1. Export spoken/timer helpers from `ConversationExecutionPhase` (or thin
   `PresenceFaceCopy` presentation-only).
2. Migrate strip → face; golden dual-surface smoke by inspection.
3. StateCard: map `executionPresentationState.kind` → face + overlay; delete
   dead dialect branches.
4. LiveNow: map snapshot fields → spoken face words only when honest.
5. Fuse StateCard sections; hosts ≤400.
6. Compress report + DONE 023 + regen-queue.

---

## Council notes (evidence)

- Ribbon only consumer of face: `ExecutionRibbon.swift`
- Strip reconnect bool: `ConversationCockpitBody.swift` ~L119+
- StateCard ~646 LOC, no face import
- Glance face: `App/Widgets/AtlasTurnGlanceGrammar.swift`
- Continuity restore BLOCKED: LEDGER Notes

## Residuals explícitos post-023

- Widget accessory forests → idle compress only
- App Group → operator portal
- 022 half-adoption closed by this wave

---

## Rank rationale

Among empty-queue axes (Código · pílula · Conversa · Continuity · Arena/Autônomos):

| Axis | Why not #1 now |
|---|---|
| Código | 019/020 pack closed; radar residual = WAVE-024 |
| Pílula | chrome+pack done; mandar-fazer Core-blocked |
| Conversa sink | 017/014/012 closed; residual is this face organ |
| Arena | 021 score + 010 suite closed |
| Continuity data | App Group BLOCKED |

**This wave is the incomplete organ** that spans Continuity + Conversa without
portal unlock.
