# WAVE-163 — change-review-pack-mid-thread-wire

**Status:** design · proposed · high
**Wave:** WAVE-163-change-review-pack-mid-thread-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual pack campaign
**Δ patamar:** **high**

## Problema
ChangeReviewJudgment.packFacts and ChangeReviewSheetJudgment.packFacts
were UI-sheet only — mid-thread OccasionPack never saw risk face / sheet
load face after WAVE-160/161 steer+handoff wires.

## Patamar
| Antes | Depois |
| review pack hollow mid-thread | PublishedSlice.changeReview wired |
| sheet face UI-only | sheet + risk packFacts in OccasionPack |

Δ = pack change-review honesty mid-thread.

## Arquitetura
### Princípios
Casca only · Zero Core · published review only · never invent findings

### Fluxo
```
ConversationSurface.rebindMidThreadTurnFacts
  → PublishedSlice.changeReview = reviews.byTrace[presenceTrace]
  → changeReviewLoadFinished = published || !inFlight
ConversationOccasionPack
  → ChangeReviewSheetJudgment.packFacts
  → ChangeReviewJudgment.packFacts
```

### Arquivos
1. ConversationOccasionPack.swift
2. ConversationSurface.swift
3. CODEMAP.md
4. design + compress + DONE + LEDGER + QUEUE

### Densidade
wire only

### Fora de escopo
Core · redesign sheet · density peels

### §5
nenhum

## DoD produto (≥5)
- [ ] Sheet packFacts from OccasionPack when presence trace
- [ ] Risk packFacts from OccasionPack
- [ ] PublishedSlice carries changeReview
- [ ] loadFinished honest (in-flight vs published)
- [ ] No invent findings
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
density · invent Core · tipografia

## Plano W3
1. slice fields 2. wire pack 3. gates 4. CODEMAP 5. DONE

## Proof
1. live trace with review → review_risk_face in pack
2. no review → absence
3. in-flight → loading face honesty
4. DEVICE_PENDING

## Council
Residual hollow ChangeReview pack after 157–162.

### Why full-bar
≥5 files · design ≥120 · DoD≥5 · product pack

### Rejection
mono rename → fail

### Related
WAVE-160 steer · WAVE-161 handoff · ChangeReview sheet UI

### Sequence after
A fill

### Acceptance
Build green · callers · DEVICE_PENDING

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Behavior unchanged

### Density table
| Module | Delta |
| OccasionPack | +20 |
| Surface | +15 |

### Product words
review_sheet_face · review_risk_face

### Files
≥5 governance+App

### Notas
inFlight Set is presentation state on ChangeReviewModel

### Anti-objetivos again
- inventar
- tipografia
- Core

### Risk
inFlight access across peels — already on model

### Recovery
revert wire

### MARK
// WAVE-163

### Guard
green required

### End design pad (canon ≥120)
Pack residual full-bar. Casca only. Zero Core. Zero área nova.
ConversationModel deferred. DEVICE_PENDING always.
Gates every App commit. Prefer product pack over density.
Idle max 2. No micro-WAVE invent.
Fila empty → residual full-bar or wait A.

---
*End WAVE-163*
