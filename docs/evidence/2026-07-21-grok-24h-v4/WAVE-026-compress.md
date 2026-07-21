# WAVE-026 W3 compress — autonomos-decision-judgment-instrument

**Date:** 2026-07-21  
**Wave:** WAVE-026  
**Implementer:** Grok B v5

## What landed (W2 DoD)

| DoD | Proof |
|---|---|
| Hub awaiting → primary CTA | `AutonomosHubView.primaryVerb` `.awaiting` → `primaryCTATitle` + `.decisions` |
| `.decisions` lists only published | `AutonomosDecisionJudgment.items` filters `decisionRequired` / `operatorDecisionRequired` |
| Exclusive faces empty/loading/items/failed | `AutonomosDecisionFace` + `AutonomosDecisionSurface` |
| decide via ReasonSheet | Surface sheet → `model.decide(...)` + error/receipt honesty |
| List elevates awaiting when bound | `rankUnits` + `awaitingUnitIDs` (only bound unit; never invent) |
| Pack subjects = real items | `AutonomosAskContext.facts(..., backlog:)` + `packSubjects` |
| Spoken ≡ face words | face.spokenFace / productWord on surface + list trailing |
| CODEMAP | "Decisão Autônomos" → Judgment → Surface → Hub/MapShell/decide |

## W3 (canon §7)

1. **Extract** `AutonomosDecisionJudgment` (pure) + `AutonomosDecisionSurface` (1 domínio)
2. **Wire** Hub / MapShell / List / AskContext / View header
3. **Delete theater** — decisions no longer "Ainda no escopo local" when organ exists; placeholder remains only for moment/incident
4. **No multi-domain fuse**; hosts stay thin

## Densities (post)

| File | LOC | Band |
|---|---:|---|
| AutonomosDecisionJudgment | ~312 | Judgment OK |
| AutonomosDecisionSurface | ~293 | Surface light OK |
| AutonomosMapShell | ~253 | Shell ≤600 |
| AutonomosHubView | ~78 | thin |
| AutonomosListView | ~137 | thin |
| AutonomosView | ~304 | route ≤600 |

## DEVICE

DEVICE_PENDING — operator passcode; product proof on device not claimed.

## Anti-patterns avoided

- No invented inbox counts
- No Core/§5 wire invent
- No fuse-as-WAVE; no micro tipografia
