# WAVE-008 — compress report

**Wave:** `WAVE-008-ops-failure-empty-canon`  
**Date:** 2026-07-21

## Δ

- New `AtlasOpsFailureEmpty` + `AtlasOpsFailureMode` (network | domainUnavailable | load)
- Thin hosts: `AtlasNetworkFailureEmpty`, `AtlasCodeLoadFailureEmpty`, `ArenaPremiumLoadFailureView`, `AutonomosFleetFailureEmpty`
- Deleted Code failure peels (6) + Autonomos failure peels (3)
- Domain-unavailable Arena mode distinct from network load

## DoD

1. One primitive consumed by Code + Arena + Autônomos + Home/Search/Conversation ✓  
2. Domain-unavailable ≠ offline (mode + kicker + symbol) ✓  
3. Fail ≠ empty preserved (no idle empty substitution) ✓  
4. Zero invented metrics in failure copy ✓  
5. A11y IDs preserved (`codeLoadFailure`, `codeLoadRetry`, `arenaPremiumState("failed-load")`, `autonomosLoadFailure`, home offline) ✓  
6. Peels orphaned deleted; `AtlasCodeLoadFailureEmpty` remains thin host ✓  
7. Gates green; no host >400 ✓

## Residual

- AtlasFailureCopy still multi-peel (copy source, not layout dialect)
- ArtifactSheet/ChangeReview empty out of scope
