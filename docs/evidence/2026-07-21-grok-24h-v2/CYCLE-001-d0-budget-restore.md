# CYCLE-001 — D0 file-budget restore (split, not leap)

## Guard
`find App/Atlas -name '*.swift' | xargs wc -l | sort -n | tail` → ConversationView 10751, Arena 5407, Code 5163, Root 3597, Autonomos 2736, ChangeReview 1738. All >400 → **hard fail B3**.

## Diagnosis
v1 (2026-07-20/21) collapsed peel forests into host monólitos then residual token craft. Pre-v1 `7ac8326e` has ConversationView **78** LOC + ~1999 App/Atlas files. Sources/ delta since 7ac = 0.

## Plan
1. Forward restore: `git checkout 7ac8326e -- App/Atlas/`
2. D0 re-measure — all *View*/Shell ≤400
3. Gates: AtlasCoreChecks + `cd App && make build`
4. Commit `fix(ui): D0 restore peel hosts pre-v1 budget (no collapse)`
5. Ledger → next LEAP #1 honesty `silenciar`→`pausar` or pílula chrome

## Anti-pattern
Not `git reset --hard`. Not fuse. Not token craft.
