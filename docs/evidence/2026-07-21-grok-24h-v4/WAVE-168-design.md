# WAVE-168 — messages-presence-composer-sheet-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-168-messages-presence-composer-sheet-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual pack campaign
**Δ patamar:** **high**

## Problema
ConversationMessagesJudgment, TurnPresenceJudgment, ComposerSheetJudgment
packFacts hollow mid-thread after 160–167 pack campaign.

## Patamar
| Antes | Depois |
|---|---|
| messages face UI-only | pack mid-thread |
| presence/Live Activity UI-only | pack organ |
| composer sheet face UI-only | pack organ |

Δ = mid-thread list/presence/sheet pack honesty.

## Arquitetura
### Princípios
Casca only · Zero Core · published turnCount/loadError/presence only

### Fluxo
```
PublishedSlice + hasLoadError + workspaceCatalogCount
  → MessagesJudgment.packFacts
  → TurnPresenceJudgment.packFacts(bubble.executionPresence)
  → ComposerSheetJudgment.packFacts(mode, workspaceCount)
```

### Arquivos
1. ConversationOccasionPack.swift
2. ConversationSurface.swift
3. CODEMAP + design + compress + DONE + LEDGER

### Densidade
wire only

### Fora de escopo
Core · density · invent presence

### §5
nenhum

## DoD produto (≥5)
- [ ] Messages packFacts
- [ ] TurnPresence packFacts
- [ ] ComposerSheet packFacts
- [ ] hasLoadError from model.loadError
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
density · invent · tipografia

## Plano W3
1. slice fields 2. wire 3. gates 4. CODEMAP 5. DONE

## Proof
1. empty thread → messages_face empty
2. live presence → presence_phase
3. DEVICE_PENDING

## Council
Residual hollows after 167 Code pack.

### Why full-bar
≥5 files · design ≥120 · DoD≥5

### Rejection
rename → fail

### Related
WAVE-164–166 mid-thread organs

### Sequence after
A fill

### Acceptance
Build green · DEVICE_PENDING

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
unchanged behavior

### Density table
| OccasionPack | +35 |
| Surface | +5 |

### Product words
messages_face · presence_phase · composer_mode_face

### Files
≥5

### Notas
modeKey from taskKind when non-empty

### Anti-objetivos again
- inventar
- tipografia
- Core

### Risk
none

### Recovery
revert

### MARK
// WAVE-168

### Guard
green

### End design pad (canon ≥120)
Pack residual. Casca only. Zero Core. Zero área nova.
ConversationModel deferred. DEVICE_PENDING always.
Gates every commit. No micro-WAVE invent.
Fila empty residual full-bar or wait A.
Prefer pack honesty over density peels.
Idle max 2. Autonomous until cancel.

---
*End WAVE-168*
