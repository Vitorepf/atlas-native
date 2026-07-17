# M61 Arena — prova A11/A12

Data: 2026-07-17

## XCUITest

- Comando: `xcodebuild ... -only-testing:AtlasDeviceProof/AtlasArenaFlowTests/testHomeArenaIndexSuiteRunReceipt ... test`
- Resultado: `** TEST SUCCEEDED **`
- Resumo: `test-summary.txt`
- Bundle: `AtlasArenaFlow.xcresult`
- Log: `AtlasArenaFlow.log`

Fluxo provado no simulador iPhone 17 Pro:

1. Home → entrada `Arena`.
2. Arena → seção `O ÍNDICE`.
3. Scroll até `SUITES` → abre `ArenaSuiteSheet`.
4. Abre `ArenaRunSheet`.
5. Campo `ator` sem `motivo` mantém submit desabilitado (422 evitado localmente).
6. Preenche motivo, envia POST real e recebe recibo `na fila, ainda não iniciado`.

## Screenshots

- `screenshots/01-arena-index.png`
- `screenshots/02-arena-suite.png`
- `screenshots/03-arena-receipt.png`

## Probe pós-run

Arquivo: `probe-after-app-run.json`

Leitura honesta:

- `GET /api/arena/runs/live` retornou `atlas.arena.runs_live.v1`.
- A tentativa final do app criou dois runs `terminal_bench`/`mockllm`:
  - `baseline` → `queued`
  - `with_atlas` → `queued`
- O recibo do app mostra `worker de medição ainda não implementado`.
- Portanto A12 provou enqueue real pelo app e presença em `runs/live`, mas não provou drenagem/scoreboard final dessa rodada.
