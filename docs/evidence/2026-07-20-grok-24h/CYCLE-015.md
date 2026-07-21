# CYCLE-015 — GraphList scroll/tail + commit rows peel forest → 2 modules

## Hipótese
16 peels (~300 LOC) da lista do grafo (scroll/body/head/refresh/tail + CommitRow/RowBuild/Handlers/Rotor) são floresta artificial. Fundir em 2 módulos.

## Fuse
- `AtlasCodeView+GraphList.swift` — content, scroll, head, body, refresh, truncation/mirror/week tail
- `AtlasCodeView+GraphListRows.swift` — ForEach, rotor, row build, init, tap handlers

## Deletes
14 peels GraphListScroll*/Tail*/Rows+CommitRow* (após fuse nos 2 hosts).

## Gates
AtlasCoreChecks + make build → green · commit `7ef806fa`
App/Atlas Swift: 1748 → 1734 · AtlasCodeView*: 54 → 40
