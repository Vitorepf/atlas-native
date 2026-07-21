# WAVE-156 W3 — residual-midhost-density-peel

## What
Multi-host residual density after idle 2/2 + empty A queue.

### Peels
| Host | Before | After host | Peels |
| AtlasCodeGraphChrome | 260 | 41 | Filter 71 · Worktree 61 · Week 105 |
| ConversationCockpitAgentRow | 251 | 52 | StripStatus 122 · StripActions 88 |
| AutonomosDecisionSurface | 293 | 76 | List 48 · Detail 86 · Sections 102 |
| AutonomosMapShell | 285 | 161 | Catalog 70 · Actions 67 (+ Routes/Ask prior) |
| NightlyProposalController | 291 | 181 | Schedule 117 |

## Behavior
Unchanged — extension peels only. private→internal where cross-file.

## Gates
- swift run AtlasCoreChecks ✓
- cd App && make build ✓
- ./scripts/grok-god-wave-guard.sh ✓
- DEVICE_PENDING (passcode)

## CODEMAP
Graph chrome · Strip peels · Decision peels · MapShell peels · Nightly schedule

## Out of scope kept
ConversationModel deferred · Judgment mid-size left (agent-optimal 200–800)

## Next
A fill QUEUE or residual only if monólito real reaparece.
