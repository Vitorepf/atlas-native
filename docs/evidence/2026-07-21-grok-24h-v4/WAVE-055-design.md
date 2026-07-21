# WAVE-055 — arena-start-receipt-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-055-arena-start-receipt-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArenaRunSheet` (~457 LOC) owns **submit spoken** (missing fields),
  **receipt card** copy, worker-gap line — **no pure Judgment**.
- Receipt face is bool soup (`isEnqueued` + `workerImplemented == false`)
  without exclusive product words for pack/a11y.
- Operator after start cannot judge **enqueued vs worker-off vs other
  status** with one grammar; multi-engine counts live only in View.
- Residual after live-control (050) and score judgment: **start organ**
  (rodar medição) still View-owned dialect.

## Patamar

| Antes | Depois |
|---|---|
| Submit missing soup | Judgment.allowsSubmit + missing list |
| Receipt ad hoc | Face: enqueued · worker_gap · started · other |
| Spoken local | Judgment spoken receipt/submit |
| No pack | Pack suites/engines/arms/receipt |

Δ = **soberania do start Arena** — fila vs worker off vs falha.

---

## Arquitetura

### Princípios

- Casca only; `AtlasArenaStartInput` + `AtlasArenaStartReceipt` already.
- Honesty: workerImplemented false elevates worker_gap even if enqueued.
- Empty engines/suites → blocked submit faces.
- One domain: Arena start sheet.

### Fluxo

```
form selection + input + lastStartReceipt
  → ArenaStartJudgment.submitFace / receiptFace / pack
  → ArenaRunSheet peels
```

### Arquivos (≥5)

- `ArenaStartJudgment.swift` (**new**)
- `ArenaRunSheet.swift`
- `CODEMAP.md`
- design + compress
- A11y optional face value

### Densidade

Judgment 200–500 · Sheet shrinks dialect.

### Fora de escopo

- Core start API  
- Live control rewrite (050)  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive receipt face: absent · enqueued · workerGap · started · other(status).
2. Exclusive submit face: ready · missing fields · no engines · no suites.
3. allowsSubmit aligns with isLocallyValidForSubmission + engines/suites published.
4. Receipt card + spoken from Judgment.
5. Submit spoken missing list from Judgment.
6. Pack facts receipt + selection.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent enqueued  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire RunSheet  
3. CODEMAP · compress · DONE · regen  

Estimativa: **5–7 files · 280–420 LOC**.

## Proof

1. Empty form → submit blocked + missing list.  
2. Enqueued receipt → face enqueued.  
3. workerImplemented false → workerGap face + copy.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Start organ residual after 050. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-055 design.*
