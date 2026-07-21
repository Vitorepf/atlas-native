# WAVE-162 — workspace-radar-hub-screen-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-162-workspace-radar-hub-screen-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual pack campaign
**Δ patamar:** **high**

## Problema
Hollow screen/hub packFacts after WAVE-157–161:
- WorkspaceScreenJudgment.packFacts never called from WorkspaceAskContext
- AtlasCodeRadarScreenJudgment.packFacts never called from RadarAskContext
- AutonomosHubJudgment.packFacts never on hub destination
Screen faces exist in UI a11y but pack lied by omission.

## Patamar
| Antes | Depois |
|---|---|
| screen packs dead | wired into AskContexts |
| hub face UI-only | pack organ on .hub |

Δ = pack screen honesty residual.

## Arquitetura
### Princípios
- Casca only · Zero Core · Honesty · wire existing packFacts
- No invent repository/thread counts

### Fluxo
```
WorkspaceAskContext.facts
  → WorkspaceScreenJudgment.packFacts(loading/offline/count)
AtlasCodeRadarAskContext.facts
  → AtlasCodeRadarScreenJudgment.packFacts(phase, repoCount)
AutonomosAskContext.facts(.hub)
  → AutonomosHubJudgment.packFacts(vestment, control, bind, transfer)
```

### Arquivos
1. WorkspaceAskContext.swift
2. AtlasCodeRadarAskContext.swift
3. AutonomosAskContext.swift
4. CODEMAP.md
5. design + compress + DONE + LEDGER + QUEUE

### Densidade
wire only · hosts unchanged

### Fora de escopo
- Core · density peels · Search (no turnFacts pill)
- ConversationModel · tipografia

### §5
`nenhum`.

## DoD produto (≥5)
- [ ] WorkspaceScreen packFacts from WorkspaceAsk
- [ ] RadarScreen packFacts from RadarAsk
- [ ] Hub packFacts on .hub destination
- [ ] No invent counts
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
- density peel
- invent Core
- tipografia
- Search fake pill

## Plano W3
1. Wire three AskContexts
2. Gates triplos
3. CODEMAP
4. DONE + compress + regen + LEDGER

## Proof / device
1. workspace empty → workspace_face empty
2. radar loading → radar_screen_face loading
3. hub open → hub_face productWord
4. DEVICE_PENDING se passcode

## Council
Residual hollow screen packs after 157–161 product campaign.

### Why full-bar
≥5 files · design ≥120 · DoD≥5 · product pack sovereignty

### Rejection
mono-file rename · density · tipografia → fail §WAVE

### Related
WAVE-071 Search screen · WAVE-073 Workspace screen · WAVE-088 hub · WAVE-161 graph

### Sequence after
A fill QUEUE or remaining hollow judgment packs

### Acceptance
Build green · callers present · DEVICE_PENDING · behavior unchanged

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Zero product behavior change — pack matches published screen faces.

### Density table
| Module | Delta |
|---|---|
| WorkspaceAsk | +20 |
| RadarAsk | +20 |
| AutonomosAsk hub | +35 |

### Product words
workspace_face · radar_screen_face · hub_face (existing)

### Files execute
3 App + CODEMAP + 5 governance

### Notas
Search still no ask pill route — skip SearchScreen pack wire.

### Anti-objetivos again
- inventar
- tipografia
- Core
- ConversationModel peel

### Risk
LoadPhase comparisons must match WorkspaceView showsLoadingShell law.

### Recovery
Revert AskContext wire if gates fail.

### MARK
// WAVE-162 comments at wire sites

### Guard
./scripts/grok-god-wave-guard.sh OK required

### End design pad (canon ≥120)
Pack residual full-bar while A queue empty.
Prefer product pack honesty over density peels.
ConversationModel deferred forever until concurrency plan.
DEVICE_PENDING always when no physical device.
Gates every App commit.
Casca only. Zero área nova. Zero Core.
Idle max 2 after waves without inventing micro-WAVE.

---
*End WAVE-162*
