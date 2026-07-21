# WAVE-051 — composer-queue-head-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-051-composer-queue-head-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual of WAVE-046 secondary)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-046 closed send readiness; residual named in design: **Fila chip is
  count-only** (`Fila · N`) — operator cannot judge **what is next** without
  opening the sheet.
- `QueuedFollowUpsSheet` spoken is also count-only; head (FIFO first message)
  is not product grammar.
- No pure `ComposerQueueJudgment` — face · head snippet · pack · spoken.
- Mid-run queue is the operator's **next act** after send — count without
  head is incomplete sovereignty.
- FIFO order is sacred (do **not** re-rank); judgment = head face + preview.

## Patamar

| Antes | Depois |
|---|---|
| Fila · N only | Face + head snippet on chip |
| Sheet spoken count | Spoken includes head |
| No pack | Pack head/count/age |
| View-owned copy | Judgment pure |

Δ = **soberania da fila** — saber o que manda a seguir em ≤5s.

---

## Arquitetura

### Princípios

- Casca only; `QueuedMessage` id/text/createdAt already.
- FIFO order unchanged (model promote/remove).
- Honesty: empty queue → empty face, chip silence (host already hides).
- Snippet: plain truncate, no invent content.
- One domain: composer follow-up queue.

### Fluxo

```
queuedMessages (FIFO)
  → ComposerQueueJudgment.face / head / chipLabel / spoken / pack
  → Composer chip label
  → Queue sheet title/spoken
```

### Módulos

| Nome | Papel |
|---|---|
| `ComposerQueueJudgment` | face · head · labels · pack |
| ConversationComposer | chip wire |
| QueuedFollowUpsSheet* | sheet wire |
| CODEMAP | queue head |

### Arquivos (≥5)

- `ComposerQueueJudgment.swift` (**new**)
- `ConversationComposerBody.swift`
- `QueuedFollowUpsSheetBody.swift`
- `A11yID.swift` if queue face id
- `CODEMAP.md`
- design + compress

### Densidade

Judgment 150–400 · peels thin.

### Fora de escopo

- Core queue store rewrite  
- Reopen send readiness 046  
- Re-rank FIFO  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: empty · single · multi(N).
2. Chip label includes head snippet when non-empty (truncated honesty).
3. Sheet spoken includes head text.
4. Pack: face, count, head prefix, ages of head/tail if present.
5. FIFO order of rows **unchanged**.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- re-order queue  
- invent text  
- Core  
- micro-WAVE rename-only  

## Plano W2/W3

1. Judgment  
2. Chip + sheet wire  
3. CODEMAP  
4. compress · DONE · regen  

Estimativa: **5–7 files · 220–350 LOC**.

## Proof

1. 1 msg → chip shows snippet, face single.  
2. 3 msgs → multi + head = first FIFO text.  
3. Empty → host hides chip.  
4. Promote/remove order still FIFO.  
5. DEVICE_PENDING.

## Council

WAVE-046 secondary residual. Empty QUEUE. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-051 design.*
