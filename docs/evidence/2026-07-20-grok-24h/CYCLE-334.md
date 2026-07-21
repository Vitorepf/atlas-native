# CYCLE 334 — Root natural-case section kickers

## D1 Sensing
- Home sectionLabel already rendered natural via sectionSpokenLabel.
- Residual ALL-CAPS: AUDITORIA badge, RECENTES search, REPOSITÓRIOS picker.
- Call sites still passed legacy UPPERCASE strings.

## D2 Plan
- Natural-case call sites + remaining mono kickers; softer tracking.
- Keep sectionSpokenLabel legacy map for safety.

## D3 Do
- RootView: Auditoria, Recentes, Repositórios; Conversas/Operação/Workspaces call sites.

## D4 Gates
- AtlasCoreChecks ✓ · make build ✓

## D5 Dual commit
- polish + docs this cycle

## D6 Next
- Conversation/Code residual ALL-CAPS: LANES, AUDITORIA, REPLAY, MONTAGEM, WORKTREES, ARQUIVOS
