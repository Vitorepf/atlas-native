# WAVE-157 W3 — arena-occasion-organ-pack-wire-instrument

## What
Wired dead Arena organ packFacts into AskContext; unified run status productWord;
extracted ArenaFleetJudgment so fleet pack ≡ FleetView rank.

### Wire
| Organ | Call site |
| Stop | AskContext when canStop (+ stop_sheet face-only absence) |
| Pipeline | execution / now live via ArenaPipelineJudgment.project |
| Start | receipt/now/plan/execution with engines+suites counts |
| RunStatus | primary run + productWord on live lines |
| Fleet | ArenaFleetJudgment.packFacts(rank) |

### Files
- ArenaFleetJudgment.swift (new)
- ArenaPremiumAskContext.swift
- ArenaPremiumFleetView.swift
- CODEMAP.md
- design/compress/DONE/LEDGER/QUEUE

## Gates
AtlasCoreChecks · make build · guard OK · DEVICE_PENDING

## Honesty
No invented receipts/engines. Stop actor/reason modal-local → explicit absence.
