# WAVE-159 residual next — WAVE-160 conversation-steer-pack-wire

**Status:** design · proposed · max  
**Wave:** WAVE-160-conversation-steer-pack-and-strip-stop-honesty  
**Owner:** casca only · residual full-bar  
**Date:** 2026-07-21  
**Created by:** implementer residual (council runner-up after 157–159)  
**Δ patamar:** **max**

## Problema
- `ConversationSteerJudgment.packFacts` exists with **zero callers** outside
  definition — hollow organ after WAVE-095 mid-thread pack campaign.
- Mid-thread OccasionPack wires LiveStrip (stop always "available") but never
  steer receipt face / draft honesty when strip shows steer CTA.
- Strip packFacts hardcodes `live_strip_stop: available` even when face is
  finished/quiet (UI hides stop) → pack lie by over-claim.
- Agent under-authorizes steer path or invents receipt status.

## Patamar
| Antes | Depois |
| Steer packFacts dead | OccasionPack wires when presence trace |
| stop always available in pack | stop only when stripShowsLiveChrome |
| no steer receipt in pack | receipt face when lastSteer for trace |
| hollow wire | pack ≡ strip + steer sheet |

Δ = soberania pack mid-thread residual.

## Arquitetura
### Princípios
Casca only · Zero Core · Honesty · published slice only · no invent draft

### Fluxo
```
PublishedSlice + lastSteerReceipt + presenceTraceId
  → ConversationSteerJudgment.packFacts(
       instruction: "" (sheet-local when unbound),
       scope: .remaining (default) or published,
       last, traceId)
  → LiveStrip.packFacts stop honesty via stripShowsLiveChrome
```

### Arquivos
1. ConversationOccasionPack.swift
2. ConversationSurface.swift (rebind slice)
3. ConversationLiveStripJudgment.swift (stop honesty)
4. CODEMAP + design + compress + DONE + LEDGER

### Densidade
pack wire only · Judgment already exists

### Fora de escopo
Core · redesign steer sheet · density peels · ConversationModel peel

### §5
nenhum

## DoD produto (≥5)
- [ ] rg callers of ConversationSteerJudgment.packFacts ≥1 from OccasionPack
- [ ] PublishedSlice carries lastSteer + presenceTraceId
- [ ] empty instruction → honest absence when sheet unbound
- [ ] strip stop pack only when live chrome shows
- [ ] No invent receipt/instruction
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
density · invent Core · always faceCTA · tipografia

## Plano W3
1. slice fields 2. wire steer pack 3. strip stop honesty 4. CODEMAP 5. DONE

## Proof
1. mid-thread live → strip stop honest
2. after steer receipt → pack has steer_receipt
3. quiet thread → absences
4. DEVICE_PENDING

## Council
Runner-up conversation-steer pack from WAVE-157/158 council.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · product pack · not density

### Rejection
rename-only · mono-file → fail

### Related
WAVE-095 can_do · WAVE-106 hydrate · WAVE-159 pattern

### Sequence after
A fill

### Acceptance
Build green · callers · DEVICE_PENDING

### W2/W3
Wire · honesty · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Sheet-local draft empty when unbound.

### Density table
| Module | Delta |
| OccasionPack | +40 |
| Surface rebind | +10 |
| LiveStrip | +15 |

### Product words
steer_face · live_strip_stop (existing)

### Files
≥5 including governance

### Notas
scope default .remaining when no sheet scope published.

### Anti-objetivos again
- inventar
- tipografia
- Core

### Risk
TraceID from bubble.executionJobId or presence — verify field.

### Recovery
omit steer wire if no trace

### MARK
// MARK: Steer pack (WAVE-160)

### Guard
required green

### End pad
Residual pack sovereignty after Arena/Partida/Autônomos.
Casca only. Zero Core. Zero área nova.

---
*End WAVE-160*
