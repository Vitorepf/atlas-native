# V4 Artifacts & Proof — evidence

Data: 2026-07-16

## Provas capturadas

- Server PHPUnit: `tests/Feature/Ai/AiTraceArtifactsControllerTest.php` passou com 8 testes / 43 assertions.
- Regressão C15: `tests/Unit/Ai/AiTraceEngineeringReviewProjectionTest.php` passou com 7 testes / 48 assertions.
- Probe HTTP efêmero contra uma instância Laravel local nova:
  - `00-probe-summary.txt`
  - `01-server-manifest.json`
  - `02-server-content.headers`
  - `02-server-content.txt`
- Core/App gates nativos antes dos commits 09 e 10:
  - `swift run AtlasCoreChecks`
  - `cd App && make build`
  - `git diff --check`

## Skips honestos

- `ATLAS_TOKEN` ausente nesta sessão, então o live-probe contra o backend real autenticado foi pulado.
- XCUITest/screenshot da linha `ARTEFATOS (N)` ficou pendente: ainda não há harness DEBUG que semeie uma conversa concluída com manifesto de artefato, e sem token não há turno real para produzir `.md` no servidor.
- Device físico permanece `device-pending`.
