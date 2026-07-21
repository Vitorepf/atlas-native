# WAVE-061 — codigo-graph-screen-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-061-codigo-graph-screen-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · after 2 IDLE · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeSurface` owns `spokenCodeScreenBusyLabel` / `Loaded` / `Label`
  and screen a11y **without pure Judgment** for the graph screen organ.
- Load phase (`LoadPhase` idle/loading/failed/loaded) plus empty graph
  (0 commits) are View-local branches; pack hosts cannot reuse
  `graph_screen_face: loading|failed|empty|ready`.
- Fail vs empty (honest absence of commits in window) are easy to
  confuse without exclusive product words — same honesty pattern as
  Why (056) / Provenance (057).
- Residual after radar/health/why/provenance/commit-row instruments:
  **mapa do grafo (tela Código)** still dialect soup on Surface.

## Patamar

| Antes | Depois |
|---|---|
| phase switch soup | Exclusive graph screen face |
| Spoken local | Judgment spoken |
| Empty only in loaded copy | Face empty vs ready |
| No pack | Pack face + nodes + repo + fail |

Δ = **soberania da tela do grafo** — loading ≠ fail ≠ empty ≠ ready.

---

## Arquitetura

### Princípios

- Casca only; `model.phase` + `graph?.nodes` already published.
- Honesty: failed uses published error string; empty nodes ≠ invent
  commits; never invent repo slug.
- One domain: código graph screen load organ (not filter chips, not
  radar fleet, not health strip).

### Fluxo

```
phase + nodeCount + repo + failMessage?
  → AtlasCodeGraphScreenJudgment.face / spoken / pack
  → AtlasCodeSurface codeScreenChrome peels
```

### Arquivos (≥5)

- `AtlasCodeGraphScreenJudgment.swift` (**new**)
- `AtlasCodeSurface.swift` (wire spoken + accessibilityValue)
- `App/Atlas/CODEMAP.md`
- `WAVE-061-design.md`
- `WAVE-061-compress.md`
- optional: pack hook on AskContext if already open (no new area)

### Densidade

Judgment 140–280 · Surface peels thin.

### Fora de escopo

- Core graph API  
- Filter chip judgment (already GraphJudgment)  
- Radar multi-repo  
- Micro tipografia  
- Continuity App Group  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: `loading` · `failed` · `empty` · `ready`
   (idle maps to loading; loaded+0 → empty; loaded+n → ready).
2. Spoken screen label from Judgment only (Surface peels).
3. Failed includes published message when present; never invent.
4. Empty uses “sem commits neste recorte” honesty (no fake nodes).
5. Pack facts: face + repo + node_count + fail_msg? + absences.
6. `accessibilityValue` = face productWord on code screen chrome.
7. Gates (`AtlasCoreChecks` · `make build` · wave-guard) + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent commits or scan state  
- fuse with Why/Provenance sheets  
- Core / Sources  
- micro-WAVE (<5 files / <120 design)  
- opacity/font ladder  

## Plano W2/W3

1. Write Judgment (face · spoken · pack · productWord).  
2. Wire Surface spokenCodeScreen* → Judgment; a11y value.  
3. CODEMAP row · compress · DONE · regen · LEDGER.  

Estimativa: **5–6 files · 220–340 LOC**.

## Proof

1. phase loading/idle → face loading, spoken “carregando”.  
2. failed(“timeout”) → face failed + message fragment.  
3. loaded + 0 nodes → empty not failed.  
4. loaded + N → ready + count.  
5. DEVICE_PENDING.

## Council

Empty QUEUE after idle peels (PlanCard · ChangeReview).  
Graph screen residual real. §WAVE pass (≥120 design · ≥5 files ·
DoD≥5 · patamar honesty).

## §WAVE self-check

1. Patamar: yes (screen face sovereignty)  
2. DoD ≥5: yes (8)  
3. Casca only: yes  
4. Design ≥120: yes  
5. Not <30min / <5 files: yes  
6. Agent-optimal density: yes  

---

## Notas

- `AtlasCodeGraphJudgment` remains filter/default slice — **different
  domain** from screen load organ.
- Anchor legend / ask pill stay on Surface/A11y; optional pack note
  `anchoring: true` only if `isAnchoring` published (not a face).

---

*End WAVE-061 design.*
