# WAVE-040 W3 — plan-execution-progress-judgment-instrument

Self-WAVE (empty queue · A-bar).

## What landed

- **`PlanJudgment`** — face (absent/pending/running/terminal), stepState,
  summaryLine, pack, spoken card/step/audit.
- **`PlanFaceStrip`** — thin exclusive face under PlanCard header
  (`plan-face`).
- **PlanCard** — step lifecycle + spoken + badge → Judgment; face strip
  wired; removed View-owned `StepState` enum.
- **Cockpit** — strip progress meta uses shared `PlanJudgment.summaryLine`
  (one dialect).
- CODEMAP plan progresso line.

## Density

| File | Notes |
|---|---|
| PlanJudgment | ~230 pure |
| PlanFaceStrip | thin |
| PlanCard | still 1 domain; ↓ dialect |

No Core. No multi-domain fuse. DEVICE_PENDING.

## Gates

AtlasCoreChecks ✓ · make build ✓ · wave-guard ✓
