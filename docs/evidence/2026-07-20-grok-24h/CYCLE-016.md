# CYCLE-016 — AtlasCodeCommitRow peel forest 30→3

## Hipótese
30 peels (~761 LOC) da linha de commit (label/meta/spine/a11y) são floresta artificial.

## Fuse
- `AtlasCodeCommitRow.swift` — host, label, meta, chrome swipe/long-press
- `AtlasCodeCommitRow+Spine.swift` — gutter, connectors, ✦/disco, decorative a11y
- `AtlasCodeCommitRow+A11y.swift` — spoken row/state/branch/tail/identity

## Deletes
27 peels após fuse.

## Gates
AtlasCoreChecks + make build → green
App/Atlas Swift: 1734 → 1707
