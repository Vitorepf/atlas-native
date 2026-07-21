# CYCLE-001 — LiveNow peel forest → 2 modules

## Hipótese
54 arquivos LiveNow (muitos ≤18 LOC) são floresta CICLO B. Fundir em:
- `LiveNowSection.swift` (chrome, header, rows, merge, spoken)
- `LiveNowRow.swift` (content, clock, timing, a11y, spoken)

## Prova pré
- `find LiveNow*.swift | wc` = 54
- zero call sites Arena classic (já morto)

## Deletes
Todos peels `LiveNowSection+*` e `LiveNowRow+*` após fuse.

## Gates
- `swift run AtlasCoreChecks`
- `cd App && make build`

## Critério fechado
- 2 arquivos LiveNow* (ou ≤3)
- build+checks verdes
- commit polish(ui)
