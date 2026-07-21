# CYCLE 250 — delete dead motion/suite/spine helpers

## Hipótese
Após contain-without-fuse e peels, restam wrappers View/motion sem call sites.

## Deletes (prova rg refs=1)
- `ChangeReviewCouncilA11y.spokenSection` — enum inteiro
- `ArenaSuiteSheet.engineCasesCaption` / `engineDurationCaption` / `engineCardCaptions` (evidenceLine cobriu)
- `AtlasCodeCommitRow.spineConnector`
- `AtlasMotion.lightImpact`, `rowTransition`, `atlasNumericTransition` (NumericTextTransition permanece — call sites vivos)

## Gates
`swift run AtlasCoreChecks` + `cd App && make build`

## Critério fechado
Menos LOC morto; zero regressão compile; commit polish(ui).
