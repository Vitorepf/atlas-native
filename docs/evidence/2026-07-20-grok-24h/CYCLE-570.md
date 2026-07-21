# CYCLE-570 — residual craft: gold-quiet secondary ink ladder (0.72)

## D1 Observe
Secondary accent ink used 0.75 / 0.78 / 0.8 as near-duplicates of section title 0.72 — visual noise.

## D2 Leap
Collapse secondary gold-quiet ink to 0.72 family step.

## D3 Cut
Casca only. No Sources/**.

## D4 Build
- RootView, ConversationView, AtlasCodeView, AutonomosView, ArenaPremiumShell:
  accent.opacity(0.75|0.78|0.8) → 0.72 (31 call sites)

## D5 Prove
AtlasCoreChecks ✓ · make build ✓ · zero leftover 0.75/0.78/0.8 accent opacities in App views

## D6 Ledger
next_leap: residual craft (0.65→0.68 steps?, micro elevation, fundir)
