# WAVE-074 — arena-run-sheet-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-074-arena-run-sheet-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual Run sheet organ)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArenaRunSheet` spoken empty engines/suites + sheet label counts live
  View-local **without pure Judgment** for the run-sheet organ.
- Start submit already uses ArenaStartJudgment (055); residual **sheet
  shell face** (empty inventory vs ready) still dialect soup.
- Pack cannot reuse `arena_run_sheet_face: empty_engines|empty_suites|ready`.

## Patamar

| Antes | Depois |
|---|---|
| Spoken count helpers | Exclusive run-sheet face |
| Empty strings local | Judgment spoken |
| No pack for shell | Pack face + engines + suites |

Δ = **soberania da folha Rodar** — sem motor ≠ sem suite ≠ pronta.

---

## Arquitetura

### Princípios

- Casca only; engines/suites published on sheet.
- Honesty: empty inventory never pretends ready.
- One domain: run sheet shell (not start receipt — 055).

### Fluxo

```
engines + installedSuites
  → ArenaRunSheetJudgment.face / spoken / pack
  → ArenaRunSheet peels
```

### Arquivos (≥5)

- `ArenaRunSheetJudgment.swift` (**new**)
- `ArenaRunSheet.swift`
- CODEMAP · design · compress

### Densidade

Judgment 120–240.

### Fora de escopo

- Core arena start  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: empty_engines · empty_suites · ready.
2. Spoken sheet/empty/count from Judgment.
3. Close/actor/reason hints on Judgment constants.
4. Pack face + counts.
5. accessibilityValue productWord on sheet.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent engines  
- fuse StartJudgment domain wrong  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire sheet  
3. CODEMAP · compress  

Estimativa: **5 files · 180–300 LOC**.

## Proof

1. no engines → empty_engines.  
2. engines, no suites → empty_suites.  
3. both present → ready.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Run sheet residual after start/suite. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-074 design.*
