# WAVE-167 — code-commit-provenance-why-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-167-code-commit-provenance-why-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual pack campaign
**Δ patamar:** **high**

## Problema
AtlasCodeCommitRowJudgment, ProvenanceJudgment, WhyJudgment packFacts were
hollow while Code Ask already had focusNode and provenanceModel available.
Pack lied by omission on focused commit biography path.

## Patamar
| Antes | Depois |
|---|---|
| focus anchors only | row + provenance + why organs |
| provenance phase unused in pack | live phase from sheets |

Δ = Code ask pack completeness for focused commit.

## Arquitetura
### Princípios
- Casca only · Zero Core · wire existing packFacts
- Never invent biography / provenance prose

### Fluxo
```
AtlasCodeSheetsModifiers turnFacts
  → provenanceModel.phase
AtlasCodeAskContext.facts(focusNode, provenancePhase, why*)
  → CommitRowJudgment.packFacts
  → ProvenanceJudgment.packFacts
  → WhyJudgment.packFacts if whyFile set
```

### Arquivos
1. AtlasCodeAskContext.swift
2. AtlasCodeSheetsModifiers.swift
3. CODEMAP.md
4. design + compress + DONE + LEDGER + QUEUE

### Densidade
wire only · AskContext grows organs not multi-domain peel

### Fora de escopo
- Core · density peels · invent why without sheet target

### §5
`nenhum`.

## DoD produto (≥5)
- [ ] Commit row pack when focusNode
- [ ] Provenance pack with live phase
- [ ] Why pack API ready when whyFile set
- [ ] Sheets pass provenanceModel into AskWhy modifier
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
- density peel
- invent biography
- tipografia

## Plano W3
1. Extend facts signature
2. Wire organs
3. Plumb provenanceModel
4. Gates + CODEMAP + DONE

## Proof / device
1. focused commit → commit_row_face + provenance_face
2. idle provenance → honest absence/loading face
3. DEVICE_PENDING se passcode

## Council
Residual hollow Code organs after 161 graph-screen and 166 multi-surface.

### Why full-bar
≥5 files · design ≥120 · DoD≥5 · product pack

### Rejection
mono-file rename · density → fail §WAVE

### Related
WAVE-161 graph screen · WAVE-043 health · WAVE-048 heal veto

### Sequence after
A fill QUEUE or remaining hollows (Search/Timeline/Reason)

### Acceptance
Build green · callers present · DEVICE_PENDING · behavior unchanged

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Zero product behavior change — pack matches published focus/provenance.

### Density table
| Module | Delta |
|---|---|
| CodeAsk | +50 |
| Sheets | +5 |

### Product words
commit_row_face · provenance_face · why_face (existing)

### Files execute
2 App + CODEMAP + 5 governance

### Notas
whyFile optional until why sheet rebind if later needed

### Anti-objetivos again
- inventar
- tipografia
- Core
- ConversationModel peel

### Risk
provenanceModel scope on AskWhy modifier — fixed by adding property

### Recovery
Revert AskContext + Sheets wire if gates fail

### MARK
// WAVE-167 at wire sites

### Guard
./scripts/grok-god-wave-guard.sh OK required

### End design pad (canon ≥120)
Pack residual full-bar while A queue empty.
Prefer product pack honesty over density peels.
ConversationModel deferred forever until concurrency plan.
DEVICE_PENDING always when no physical device.
Gates every App commit. No micro-WAVE invent.
Casca only. Zero área nova. Zero Core.
Idle max 2 after waves without inventing micro-WAVE.
Autonomous factory until cancel.

---
*End WAVE-167*
