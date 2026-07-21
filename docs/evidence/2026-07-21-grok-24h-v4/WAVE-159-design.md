# WAVE-159 — autonomos-selfconstruction-veto-pack-and-can-do

**Status:** design · proposed · max  
**Wave:** WAVE-159-autonomos-selfconstruction-veto-pack-and-can-do  
**Owner:** casca only · residual full-bar (fila empty after 157/158)  
**Date:** 2026-07-21  
**Created by:** implementer residual (council runner-up WAVE-157/158)  
**Δ patamar:** **max**

## Problema
- SelfConstructionVetoJudgment tem absences/canRevert **sem packFacts** e
  **zero wire** em AutonomosAskContext — pílula ignora veto merge-proved.
- NightlyProposalJudgment.packFacts e AutonomosRhythmJudgment.packFacts
  existem (rg defs only no catálogo) — hollow wire no pack do shell.
- can_do Autônomos (088) eleva faceCTALocal por loop/decisão, mas **não**
  documenta veto retroativo como CTA face-only quando canRevert.
- Banner/sheet de self-construction na UI ≠ pack — mentira por omissão.

## Patamar
| Antes | Depois |
| veto pack morto | packFacts + absences wired |
| nightly/rhythm pack dead | catalog pack organs |
| can_do sem veto honesty | absences + face CTA quando canRevert |
| pílula cega ao merge-proved | pack ≡ face (veto sheet / banner) |

Δ = soberania pack Autônomos residual pós-088/157/158.

## Arquitetura
### Princípios
Casca only · Zero Core · Honesty never invent merge/receipt · 088 pétreo extend

### Fluxo
```
AutonomosAskContext.facts(...)
  → existing loop/bind/transfer/health/fleet/digest/can_do
  → SelfConstructionVetoJudgment.packFacts(receipt?, canControl)
  → if catalog (destination nil):
       NightlyProposalJudgment.packFacts(...)
       AutonomosRhythmJudgment.packFacts(windows, paused)
  → AutonomosCanDoJudgment.packFacts(... canRevert:)
```

### Arquivos
1. SelfConstructionVetoJudgment.swift — packFacts
2. AutonomosAskContext.swift — wire
3. AutonomosMapShellAsk.swift — pass receipt/nightly/rhythm
4. AutonomosCanDoJudgment.swift — canRevert honesty
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
Judgment +50 · AskContext wire only · no shell peels

### Fora de escopo
Core · tipografia · density peels · redesign receipt sheet

### §5
nenhum

## DoD produto (≥5)
- [ ] packFacts on SelfConstructionVetoJudgment
- [ ] AskContext wires veto pack when merge-proved or honest absence
- [ ] Nightly + Rhythm packFacts on catalog destination
- [ ] can_do absences mention veto face CTA when canRevert
- [ ] No invent of merge hash / cycle
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
density peel · invent Core · always faceCTALocal · tipografia

## Plano W3
1. packFacts veto 2. wire ask 3. can_do 4. nightly/rhythm 5. CODEMAP 6. DONE

## Proof
1. merge-proved + canControl → pack veto face + can_revert
2. no receipt → absence
3. catalog → nightly/rhythm faces
4. DEVICE_PENDING

## Council
Runner-up from WAVE-157/158 council. Fila A empty.

### Why full-bar
≥5 files · design ≥120 · DoD≥5 · product pack sovereignty · not density

### Rejection
rename-only · fuse · mono-file → fail

### Related
WAVE-033 veto UI · WAVE-088 can_do · WAVE-070 nightly · WAVE-157/158 pack

### Sequence after
A fill or conversation steer pack residual

### Acceptance
Build green · packFacts callers · DEVICE_PENDING · behavior honesty only

### W2/W3
Wire · can_do · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Behavior of controls unchanged; pack matches face.

### Density table
| Module | Target |
| Veto packFacts | ≤80 add |
| AskContext wire | ≤80 add |
| CanDo | ≤40 add |

### Product words
veto · can_revert · nightly_face · rhythm_face (existing)

### Files execute
5+ App + governance

### Notas
latestMergeProvedReceipt already on MapShell — pass into facts.

### Anti-objetivos again
- inventar
- tipografia
- Core
- ConversationModel

### Risk
async rhythm windows — use published AtlasSession.rhythm if available sync path.

### Recovery
gate fail → revert AskContext wire only.

### MARK
// MARK: Pack on VetoJudgment

### Guard
grok-god-wave-guard OK required

### End design pad
Residual product after 157/158 product max waves.
Empty queue · idle not preferred over product pack.
Do not density peel ConversationModel.
Casca only. Zero área nova. Zero Core.

---
*End WAVE-159*
