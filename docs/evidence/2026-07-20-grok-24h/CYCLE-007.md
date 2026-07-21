# CYCLE-007 — RootHomeSections peel forest → 1 module

## Hipótese
26 peels (~423 LOC) da home (CONVERSAS/OPERAÇÃO/WORKSPACES/LiveNow gate) são floresta. Fundir em `RootHomeSections.swift`.

## Deletes
Todos `RootHomeSections+*.swift` após fuse.

## Gates
AtlasCoreChecks + make build
