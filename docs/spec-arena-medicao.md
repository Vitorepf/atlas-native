# SPEC M61 — O Cockpit de Medição dos Motores (a única tela nova)

> **Para a IA executora, sem contexto prévio.** Spec completa da única tela
> nova autorizada do atlas-native. Hierarquia: canon do operador > esta spec
> > `docs/plano-profundidade-total.md` (M61) > OBRA.md > improviso.
>
> **NOME:** o vocabulário "Rivals"/"benchmark" é proibido no código da
> equipe Criação (regra Criação≠Medição do canon-pai). **Default autorizado
> pelo operador ao despachar esta spec:** código `AtlasArena*`, rota
> `.arena`, título exibido "Arena". Se o operador declarar outro nome na
> sessão, use-o em TODOS os símbolos (um search-replace no início, nunca
> misto). O lado servidor PODE manter o namespace interno Rivals (é o time
> de Medição) — a API pública e os schemas usam `arena`.
>
> **Escopo pleno decidido pelo operador (2026-07-17, OBRA §6):** índice
> consolidado das ~10 suites + medições rodando agora com braço visível +
> ação governada de rodar + perfil de capacidades + todas as métricas com
> gráficos. "O maior e mais completo — roda 10 medições e consolida o
> resultado das 10."

## §A · Descoberta primeiro (o que JÁ existe no servidor)

Antes de escrever qualquer contrato, ler no `../atlas-server`:
- `config/atlas_rivals.php` — config do domínio de medição.
- `app/Services/Ai/Rivals/**` — adapters (ex.:
  `Adapters/External/AbstractExternalSuiteAdapter.php`) e serviços.
- `scripts/rivals-atlas-dev-bridge.php` — a ponte "braço com Atlas".
- `tests/Feature/Ai/Rivals/**` + `tests/Fixtures/Rivals/cases/**`
  (ex.: `terminal_bench/tb_git-multibranch.json`) — o padrão de teste.
- `rg -n "with_atlas|baseline|arm" app/Services/Ai/Rivals` — como o braço
  comparativo é registrado hoje.

Mapear: quais suites têm adapter instalado; onde os resultados persistem
(tabelas/receipts); se existe score por rodada e por braço. O QUE FALTAR
(composto, capacidades, runs live, start governado) É PARTE DESTA SPEC —
nunca contornado, nunca inventado na casca.

## §B · Os 5 contratos públicos `atlas.arena.*.v1` (allowlist absoluta)

Regra transversal: NUNCA prompt, caso, fixture, log, stdout, path interno.
Só números, nomes públicos de suíte/motor/capacidade, timestamps, hashes de
recibo. Todos fail-closed por `requireSchema` no Core.

### B1 · `GET /api/arena/composite` — O ÍNDICE CONSOLIDADO
```json
{ "schema_version": "atlas.arena.composite.v1",
  "generated_at": "…",
  "suites_total": 10, "suites_measured": 8,
  "weights_public": { "terminal_bench": 0.15, "inspect_evals": 0.10, "…": 0 },
  "engines": [ {
    "engine": "codex_cli",
    "composite": 0.83, "previous": 0.79, "delta": 0.04,
    "with_atlas_composite": 0.92, "without_atlas_composite": 0.75,
    "atlas_multiplier": 1.23,
    "coverage": 0.8,
    "history": [ { "round_at": "…", "composite": 0.79,
                   "with_atlas": 0.90, "without_atlas": 0.73 } ] } ] }
```
Regras do composto (no SERVIDOR, testadas): pesos somam 1.0 e são config
versionada (`config/atlas_arena.php`); suíte não-medida NÃO entra no
denominador — `coverage` diz quanto do índice está medido; `atlas_multiplier`
= with/without SÓ quando ambos os braços têm rodada na mesma janela; motor
sem nenhuma rodada não aparece (ausência, não zero).

### B2 · `GET /api/arena/scoreboard` — por suíte × motor
```json
{ "schema_version": "atlas.arena.scoreboard.v1",
  "suites": [ { "suite": "terminal_bench", "runs_total": 12,
    "last_run_at": "…", "adapter_installed": true,
    "engines": [ { "engine": "codex_cli",
      "score": 0.81, "previous_score": 0.78, "delta": 0.03,
      "with_atlas_score": 0.91, "without_atlas_score": 0.74,
      "atlas_multiplier": 1.23,
      "cases_passed": 34, "cases_failed": 8, "cases_total": 42,
      "duration_avg_ms": 48200, "regressed": false,
      "history": [ { "round_at": "…", "score": 0.78, "arm": "baseline" } ]
    } ] } ] }
```

### B3 · `GET /api/arena/capabilities?engine=` — habilidades medidas
```json
{ "schema_version": "atlas.arena.capabilities.v1",
  "mapping_version": "arena.capability_map.v1",
  "capabilities": [ { "capability": "terminal_operation",
    "label_pt": "Operação de terminal",
    "score": 0.86, "with_atlas": 0.93,
    "suites_contributing": ["terminal_bench"], "cases_total": 42 } ] }
```
O mapeamento suíte→capacidade é CONFIG PÚBLICA versionada no servidor
(`config/atlas_arena.php` → `capability_map`) — a casca nunca inventa
taxonomia. Dimensões iniciais sugeridas (ajustar ao que as suites cobrem):
operação de terminal, edição de código, correção de bugs, raciocínio,
recuperação de contexto, uso de ferramentas.

### B4 · `GET /api/arena/runs/live` — rodando agora
```json
{ "schema_version": "atlas.arena.runs_live.v1",
  "runs": [ { "run_id_public": "…", "suite": "terminal_bench",
    "engine": "codex_cli", "arm": "with_atlas",
    "status": "running", "cases_done": 17, "cases_total": 42,
    "started_at": "…" },
    { "…": "…", "status": "queued", "queued_at": "…" } ] }
```

### B5 · `POST /api/arena/runs` — rodar (governado)
```json
{ "suites": ["terminal_bench"],           // ou "all" (as com adapter)
  "engine": "codex_cli",
  "arms": ["baseline", "with_atlas"],
  "operator_actor": "…", "operator_reason": "…" }
→ 202 { "status": "enqueued", "receipt_hash": "…",
        "runs_planned": 2 }
```
Liturgia governada (igual Autônomos): ator+motivo obrigatórios (422 sem);
suíte sem adapter → 422 `adapter_missing` (e a casca nem oferece);
o recibo é "na fila · ainda não iniciado" — SÓ `runs/live` prova execução.
Execução real = worker de medição (descobrir/usar o mecanismo Rivals
existente; se não houver worker, o enfileiramento honesto + §5).

## §C · Servidor — o que construir (PHPUnit red→green em tudo)

1. `config/atlas_arena.php`: `weights` (soma 1.0, validada), `capability_map`
   (suite → [capability, weight]), `suites` habilitadas.
2. `ArenaCompositeService` (puro): score composto por motor/braço a partir
   dos resultados persistidos; cobertura; história por rodada. Testes:
   pesos parciais, braço único (sem multiplier), motor sem rodada, janela.
3. `ArenaCapabilityProfileService` (puro): agrega por capacidade via
   capability_map. Testes: suíte em 2 capacidades, capacidade sem suíte
   medida (ausente).
4. `ArenaRunsLiveService` + registro de progresso (se os adapters já
   emitem progresso por caso, projetar; senão `cases_done` ausente — dito).
5. `ArenaRunController`: os 4 GET + o POST governado (recibo persistido).
6. Rotas em `routes/api.php` sob auth padrão. `place-feature` antes.
7. Knowledge sync + index-code ao final.

## §D · Core (Sources/AtlasCore) — DTOs e client

`AtlasArena.swift` (~250 linhas): `AtlasArenaComposite`, `AtlasArenaScoreboard`,
`AtlasArenaCapabilities`, `AtlasArenaLiveRuns`, `AtlasArenaStartInput/Receipt`
— todos `requireSchema`, campos opcionais onde o servidor pode omitir
(fail-open em bag, fail-closed em schema). Client: `getArenaComposite()`,
`getArenaScoreboard()`, `getArenaCapabilities(engine:)`, `getArenaLiveRuns()`,
`startArenaRuns(input:)`.
Golden checks (`AtlasArenaChecks.swift`): decode dos 5; schema errado
fail-closed; multiplier ausente com braço único; coverage parcial; input
sem motivo inválido localmente (`isLocallyValidForSubmission`, padrão
Autônomos).

## §E · Casca — a tela (rota nova AUTORIZADA)

- `Route.arena` no enum + entrada na home, seção OPERAÇÃO (linha irmã de
  Autônomos): ícone próprio (sugestão: `chart.line.uptrend.xyaxis` até arte
  própria), sublinha por exceção ("hermes regrediu −0.05"), badge SÓ com
  regressão.
- `ArenaModel` (@MainActor @Observable, `LoadPhase`, read-cache/selo de
  idade F6.1): `composite`, `scoreboard`, `capabilities`, `liveRuns`
  (polling 10s SÓ com a tela visível e runs não-vazios), `lastStartReceipt`.
- `AtlasArenaView` (< 400 linhas, seções em arquivos próprios se crescer):

```
┌ ARENA · MEDIÇÃO DOS MOTORES ─────────────────┐
│ ⚠ inspect_evals · hermes regrediu −0.05      │ ← exceções SEMPRE primeiro
├─ AGORA ──────────────────────────────────────┤ ← só com run vivo
│ ● terminal_bench · codex · COM ATLAS  17/42  │
│ ○ swe_like · claude · baseline · na fila     │
├─ O ÍNDICE ───────────────────────────────────┤
│  codex  0.83 ▲+0.04  c/Atlas 0.92  ×1.23     │ ← N×M medido
│  claude 0.86 ▬       c/Atlas 0.94  ×1.31     │
│  cobertura 8/10 · pesos ⓘ                    │ ← parcial DITO
│  [Swift Charts: linhas do composto/rodada]    │
├─ CAPACIDADES ────────────────────────────────┤
│  terminal      ████████░░ .86  ▓▓ .93 c/A    │ ← barras duplas
│  edição código ███████░░░ .74  ▓▓ .88 c/A    │
├─ SUITES ─────────────────────────────────────┤
│  TERMINAL_BENCH · 12 rodadas · há 2h [spark] │ → ArenaSuiteSheet
├──────────────────────────────────────────────┤
│              [ ▶ Rodar medição ]             │ → ArenaRunSheet
└──────────────────────────────────────────────┘
```

- **Sheets** (profundidade, não telas): `ArenaSuiteSheet` (por motor: casos
  ✓/✗, duração média, série completa com braço por ponto),
  `ArenaEngineSheet` (série composta + capacidades do motor),
  `ArenaRunSheet` (multi-select de suites COM adapter · motor · braços
  [default: os dois] · ator+motivo — botão desabilitado sem eles · após 202:
  recibo "na fila · ainda não iniciado").
- **Gráficos:** Swift Charts (Apple, `import Charts` — ZERO dependência
  externa): LineMark (séries), BarMark duplo (capacidades), sparklines
  (LineMark mini sem eixos). `chartLegend` acessível; Reduce Motion → sem
  animação de traçado; cores APENAS `AtlasTheme` (baseline `textSecondary`,
  com-Atlas `accent`, regressão `alert` — cor é estado).
- **Estados:** carregando (diamond) · servidor sem domínio arena → tela
  indisponível explícita ("medição ainda não publicada pelo servidor") ·
  suíte sem rodada → "não medido" cinza (NUNCA verde) · snapshot velho →
  selo de idade.
- **Live Activity:** "Seguir" um run vivo (long-press) → LA com
  `suite · engine · BRAÇO · casos N/M` — herda SD-2/M93; fase terminal
  encerra (C14).
- **A11y:** `A11yID.arena*` completo (tela, linhas, sheets, botão rodar);
  VoiceOver por linha: "codex, composto 0.83, subiu 0.04, com Atlas 0.92,
  multiplicador 1.23". Dynamic Type via AtlasFont; números `mono` tabulares.

## §F · Ordem de commits (12)

```
A1 server  config/atlas_arena.php + ArenaCompositeService (PHPUnit)
A2 server  ArenaCapabilityProfileService (PHPUnit)
A3 server  runs live + start governado + rotas (PHPUnit + probe real)
A4 core    AtlasArena DTOs + client + golden checks
A5 ui      Route.arena + entrada na home (badge por exceção)
A6 ui      ArenaModel + seção O ÍNDICE (+ gráfico de linhas)
A7 ui      seção CAPACIDADES (barras duplas)
A8 ui      seção SUITES + ArenaSuiteSheet + ArenaEngineSheet
A9 ui      seção AGORA (polling visível-only) + ArenaRunSheet (start)
A10 ui     Live Activity "Seguir medição"
A11 test   XCUITest: home→arena→índice→suite→rodar(422 sem motivo)→recibo
A12 prova  rodada REAL disparada do app → AGORA → scoreboard; screenshots;
           §7 + evidence
```
Gates em todos; live-probe no A3/A12; device para A10/prova final.

## §G · DoD + riscos

**DoD:** os 5 contratos com PHPUnit verdes; rodada real do app aparecendo em
AGORA e depois no scoreboard/composto; cobertura parcial exibida como
parcial; suíte sem adapter invisível no run sheet; zero regressão nos
gates; XCUITest verde; screenshots + device; §7 registrado. `rg "case "
RootView` = +1 rota exatamente (.arena).

**Riscos:** (1) resultados históricos do Rivals podem não ter braço/rodada
estruturados → normalizar no serviço com testes, nunca na casca; (2) rodar
"all" pode levar horas → o run sheet mostra estimativa SE houver
duration_avg histórico (senão nada) e o recibo deixa claro que é fila;
(3) worker de medição pode não existir para start remoto → enfileiramento
honesto + §5 com o que falta; nunca simular progresso.
