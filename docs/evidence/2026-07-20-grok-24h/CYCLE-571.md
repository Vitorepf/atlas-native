# CYCLE-571 — residual craft: fundir AtlasGoldBreathHairline

## D1 Observe
Gold-breath LinearGradient 0/0.28/0.12 duplicated across Home, Conversa, Código, Arena, Autônomos, Review (~170 lines).

## D2 Leap
delete>fundir: one theme component, call sites keep padding/inset.

## D3 Cut
Casca only. Theme + views.

## D4 Build
- AtlasTheme: `AtlasGoldBreathHairline` peaks single/double/fadeIn/fadeOut
- Replaced call sites in RootView, ConversationView, AtlasCodeView, AutonomosView, ArenaPremiumShell, ChangeReviewView
- Net −118 lines casca (55+/173−)

## D5 Prove
AtlasCoreChecks ✓ · make build ✓

## D6 Ledger
next_leap: residual craft (remaining flat hairlines, gold opacity steps, micro)
