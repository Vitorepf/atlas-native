# CYCLE-017 — AtlasCodeView sheets peel forest 17→2

## Hipótese
17 peels da folha do grafo (forward→wrap→init→modifier + provenance/heal + ask/why) são cadeia de peels sem valor.

## Fuse
- `AtlasCodeView+Sheets.swift` — atlasCodeSheets entry, codeSheetsBind, SheetsModifier + provenance/heal
- `AtlasCodeView+Sheets+AskWhy.swift` — ask conversation + why file sheets

## Deletes
15 peels intermediários (Forward/ModifierWrap/Init/Bind/Provenance*/Heal*/AskSheet…).

## Gates
AtlasCoreChecks + make build → green
App/Atlas Swift: 1707 → 1692 · AtlasCodeView*: 40 → 25
