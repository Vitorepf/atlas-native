# WAVE-039 W3 — change-review-risk-judgment-instrument

Self-WAVE (empty queue · idle_compress=4 · A-bar).

## What landed

- **`ChangeReviewJudgment`** — pure risk grammar: severityRank, rankFindings,
  rankedAxisGroups (worst-axis first), rankPatches (riskFlags-first),
  rankControls/rankTests (fail-first), face · summary · pack · spoken,
  severity color/spoken.
- **`ChangeReviewRiskStrip`** — thin exclusive face chrome (`review-risk-face`).
- **Findings** — no alpha axis sort; Judgment groups.
- **Patches** — ranked before cards.
- **Controls/tests** — fail-first order.
- **Sheet spoken** includes risk face supplement.
- **`hasReviewSurface`** delegated to Judgment (single honesty gate).
- Severity helpers removed from FindingRow (→ Judgment).
- CODEMAP: change-review risk → Judgment.

## Density

| File | Role |
|---|---|
| ChangeReviewJudgment | ~280 pure Judgment |
| ChangeReviewRiskStrip | thin strip |
| ChangeReviewSections | still 1 domain · ranks wired |
| ChangeReviewView | spoken face |

No file >2000. No multi-domain fuse. No Core.

## DoD

1–9 design DoD met in casca (DEVICE_PENDING for device visual).

## Proof

- AtlasCoreChecks ✓  
- `cd App && make build` ✓  
- grok-god-wave-guard (post-commit stage)

DEVICE_PENDING (passcode).
