# CYCLE 252 — Autônomos dead transfer/decide + honest startRun

## Hipótese
Face v9 desligou sheets transfer/decide/control; model peels e receipts ficaram mortos.
`startRun` no-op silencioso sem `selectArea` (nunca chamado na UI).

## Deletes
- `AutonomosModel+Transfer.swift` (entire)
- `AutonomosModel+Decide.swift` (entire)
- props: lastTransfer/Revert/Decision/ControlReceipt, canControlSelectedArea, selectArea, control()

## Honesty
- `runTargetArea`: seleção ou única área registrada
- `startRun` error copy se 0 ou N>1 registradas — zero no-op

## Gates
checks + make build
