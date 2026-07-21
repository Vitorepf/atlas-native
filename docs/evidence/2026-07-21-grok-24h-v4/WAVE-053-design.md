# WAVE-053 — conversation-steer-receipt-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-053-conversation-steer-receipt-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Steer sheet mid-run owns **canSubmit**, receipt copy, scope spoken in
  View peels — **no pure `ConversationSteerJudgment`**.
- Scope picker shows **raw wire values** (`current_step` / `replan`) —
  not product PT words for the operator.
- Receipt accepted/rejected is a one-line View dialect; rejection reason
  can surface raw enum; face not exclusive for pack/a11y hosts.
- After decision strip (031) and send readiness (046), residual **steer
  organ** (redirecionar execução) still View-owned soup.
- Matched receipt (trace-scoped) logic is correct but not Judgment-owned.

## Patamar

| Antes | Depois |
|---|---|
| canSubmit bool local | Judgment.allowsSubmit |
| Scope raw wire | productWord PT no picker |
| Receipt ad hoc | Face accepted/rejected + spoken |
| No pack | Pack instruction scope receipt |

Δ = **soberania do redirecionamento** — saber se enfileirou ou recusou.

---

## Arquitetura

### Princípios

- Casca only; `AtlasInteractionSteerResponse` already on model.
- Honesty: mismatched trace → silence (no show wrong receipt).
- Empty instruction → not ready (never invent instruction).
- One domain: conversation steer mid-run.

### Fluxo

```
instruction + scope + lastSteerReceipt + traceId
  → ConversationSteerJudgment.face / allowsSubmit / scopeLabel / receiptLine / pack
  → SteerInteractionSheet peels
```

### Módulos

| Nome | Papel |
|---|---|
| `ConversationSteerJudgment` | face · submit · scope · receipt · pack |
| SteerInteraction* | wire |
| CODEMAP | steer face |

### Arquivos (≥5)

- `ConversationSteerJudgment.swift` (**new**)
- `SteerInteractionBody.swift`
- `SteerInteractionSheet.swift` (if thin host needs face)
- `CODEMAP.md`
- design + compress
- A11y optional

### Densidade

Judgment 150–400 · Body shrinks dialect.

### Fora de escopo

- Core steer API  
- Decision strip re-open  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: composing · ready · accepted · rejected (product words).
2. allowsSubmit only when instruction non-empty (trim honesty).
3. Scope picker labels PT product words (not raw wire).
4. Receipt line + spoken from Judgment; reason humanized when published.
5. Matched receipt (trace) gate in Judgment.
6. Pack facts for accepted/rejected/absence.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent acceptance  
- show mismatched-trace receipt  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire body + picker  
3. CODEMAP · compress · DONE · regen  

Estimativa: **5–7 files · 250–400 LOC**.

## Proof

1. Empty field → submit disabled · face composing.  
2. Text → ready · submit enabled.  
3. Accepted receipt → green face queue next checkpoint.  
4. Rejected → operational tint + reason.  
5. DEVICE_PENDING.

## Council

Empty QUEUE after 052. Steer residual real. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-053 design.*
