# Fable 5 → Runtime fidelity matrix

> Baseline Elite A4.5 · 2026-07-17 · fonte de cenas: `docs/proposals/fable-5.html`
> (Ato II 01–13 + Fleet + Island) · canon: `docs/plano-elite-agentica-24x7.md` ·
> blackboard: `OBRA.md`.

## Canon (não negociar)

| Regra | Implicação |
|---|---|
| **Voice / cena 09** | **EXCLUDED** — vertical futura; zero microfone/LiveKit/UI “em breve” nesta obra. |
| **Session Hub** | = deepen de `LiveNowSection` na home — **nunca** `SessionHubView` / rota nova. |
| **Arena** | Rota própria já existente (`.arena`) — medição, **fora** das cenas 01–13; ver nota abaixo. |
| **Autônomos / Fleet** | Área 24/7 própria (rota `.autonomos`) — não é card de Session Hub. |
| **Ausência de contrato** | = ausência de UI. Casca só projeta models/Core. |

## Elite A4.5 — checkbox progress

Fonte: `docs/plano-elite-agentica-24x7.md` · Onda A4 · Task A4.5.

| Checkbox | Status |
|---|---|
| Mapear cenas 01–08, 10–13 + Fleet + Island → model → view → teste → evidência → gap | **DONE** (este doc) |
| Voice marcada EXCLUÍDA | **DONE** (cena 09 abaixo) |

Deepen de fidelidade por superfície continua em A4.1–A4.4 / E-A4 — esta matriz é o inventário honesto, não o fechamento da onda A4.

---

## Matrix

| Scene | Fable intent | Runtime source (Core/model) | SwiftUI owner | Device proof | Gap (honest) |
|---|---|---|---|---|---|
| **01 · Atenção necessária** | Sessão pausa de verdade; timer congela na pergunta tipada; ações do servidor; nunca “trabalhando…” falso | `AtlasExecutionPresentationState` (`.attentionRequired` + `timer.paused`); `ConversationModel` projeta `bubble.executionPresentationState`; `choose`/ações do job | `ExecutionStateCard` ← `ConversationChrome` | device-pending (U3/E-A6; `passcodeRequired`) | **PARCIAL** — timer `‖` + spoken «tempo ativo congelado» quando `timer.paused` (`c6017af`); permissões tipadas §5 + XCUITest pausa ainda device-pending |
| **02 · Replanejamento honesto** | Plano corta/risca passo na frente; “por que mudou”; v1 arquivado; comparar versões | `AtlasExecutionPlan` + `executionProgress`; `AtlasTraceGovernance.planRevisions`; kind `.replanning` no presentation state | `PlanCard` (N/M + “comparar versões”); `ExecutionStateCard` p/ `.replanning` | device-pending | **PARCIAL** — `PlanCard` silêncio sem plano; N/M só `executionProgress` real; RM + revisões a11y (`204b2ea`); C21 archive completo ainda depende do server |
| **03 · Reconexão sem perda** | Queda → tentativas → resume na seq seguinte; cronômetro não zera | `InteractionRun` (`.reconnecting`); `ConversationModel` → `reconnectNotice`; presentation `.recovering` | `ConversationCockpit` (banner); `ExecutionStateCard` | sim parcial (stream live-probes M06); device físico pendente | Runtime shipado; prova física do timer atravessando queda ainda device-pending |
| **04 · Aguardando sistema externo** | Espera nomeada ≠ pensamento; “pode sair”; lock avisa | `AtlasExecutionPresentationState.awaitingExternal` (+ `deadline` opcional) | `ExecutionStateCard`; fase em `TurnPresence` / Live Activity | device-pending | **PARCIAL** — peel `+AwaitingFailed`: deadline só publicado; «pode sair» só com `timer.paused` (`b41d880`); lock accessory `‖` timer em pausa (`70aec79`); receipts externos ricos + auto-advance ainda server/device-pending |
| **05 · Orquestra de agentes** | Vários agentes mudando estado ao vivo; barra da obra; divergência resolvida | `AtlasAgentActivity` + jobs/`ExecAgent`; `InteractionRun` events; lanes M95 | `LiveTimeline`; `ConversationCockpit`; progress via `executionProgress` | device-pending (cockpit sim Hermes/Kimi em §7 C7/U3) | **PARCIAL** — atividades 1:1 + spoken orquestra/passo N/M + RM chips (`717f2d0`/`98b35ff`); cast multi-papel Fable + prova 2+ jobs ainda gap |
| **06 · Missão noturna** | Madrugada em marcos; resumo ao acordar; Autônomos | `NightlyProposalController` + `AtlasSession` mute; `AutonomosModel` / digest; **não** é sessão de conversa | `NightlyProposalCard` em `AutonomosView` / `RootView`; rota Autônomos | XCUITest `AtlasNightlyProposalTests` + evidence `2026-07-16-proposta-21h/`; device-pending | **PARCIAL** — spoken card/accept/mute + `NightlyProposal+Copy`/`+A11y` peels (`74d47f1`); teatro madrugada 23:10→07:30 completo + digest device ainda A4.2/device-pending |
| **07 · Revisão entre agentes** | Pareceres por papel; objeção muda implementação; consenso sem raciocínio privado | `AtlasTraceGovernance.councilReview` / `councilDiverged` (metadata); ChangeReview trace | `ChangeReviewSheet` painel council (M10) | device-pending | **PARCIAL** — council status verbatim + divergência só `councilDiverged` + file/run a11y (`41c9d21`/`168a52e`); **C20 `agentVerdicts`/consensus** ainda aberto — não inventar votos |
| **08 · Continuidade entre devices** | Handoff iPhone↔Mac/Terminal; mesma thread; zero prompt duplicado | `ConversationModel+Continuity.handoffToSurface`; `AtlasAiSurfaceDestination`; recibo `latestSurfaceHandoff` | Menu continuidade + `handoffReceipt` em `ConversationView`; LiveNow badge remoto (`sessions/live`) | device-pending | **PARCIAL** — recibo ready/pending + `createdAt` relativo + «sem prompt duplicado» + A11yID (`c6017af`); theater multi-device/deep-link ainda device-pending; **não** vira Session Hub route |
| **09 · Voz contínua** | Ouvindo → respondendo → executando (ilha) | — | — | — | **EXCLUDED** — Voice vertical futura (OBRA §4 aviso + Elite constraints). Zero trabalho nesta matriz |
| **10 · Artefato pronto** | Entrega monta com checks; ações só após prova | `AtlasTraceArtifacts` via `ChangeReviewModel.refreshArtifacts`; quality no cockpit | `ArtifactSheet`; linha em `ConversationChrome` / `ExecutionStateCard` completed | evidence `2026-07-16-artifacts/`; device/live token pendentes | **PARCIAL** — montagem animada só com provas reais do contrato + RM + vazio quieto (`44bd389`); prova iPhone/trace real ainda device-pending |
| **11 · Fila durante a execução** | Send durante turno → fila; chip N; promote/remove; FIFO drena | `QueuedFollowUpStore` / `AtlasQueuedFollowUp`; `ConversationModel.queuedMessages` + `queue`/`promote`/`removeQueued` | Chip + sheet em `ConversationView` | sem XCUITest promote/remove/FIFO dedicado; device-pending | **PARCIAL** — folha FIFO com posição/promote/remove a11y + RM (queue sheet); **A4.1 pede XCUITest** promote/FIFO — ainda gap |
| **12 · Revisar mudanças** | Diff vivo; aceitar/rejeitar por arquivo/run; ledger | `AtlasChangeReview` / `ChangeReviewModel` (C15/C16) | `ChangeReviewSheet` (`ChangeReviewView.swift`) | device-pending; falta trace real + print | **PARCIAL** — file/run actions a11y + hash warning + diff editorial (`168a52e`); journey E2E com patch/trace real ainda device-pending |
| **13 · Falha honesta do turno** | Falha nomeada + motivo + Retomar do checkpoint | `.failed` + `checkpoint` em presentation state; `retryableJobId` / C17 retry | `ExecutionStateCard` (“Retomar”) | device-pending | **PARCIAL** — spoken failure + Retomar só com `retryableJobId` real (`b41d880`); diagnóstico rico + resume seq exata ainda dependem do server |
| **Fleet · Command Center** | Frota viva: uptimes, heartbeats, lease/atenção, transferir c/ prova, digest 14:00 | `AtlasAutonomos*` via `AutonomosModel` (fleet, digest, transfer, history, live) | `AutonomosView` (+ sheets); widgets frota leem `AtlasNativeSnapshot.fleet` | sim parcial Autônomos/Nightly; device-pending; heal→merge M01 BLOCKED(server) | **PARCIAL** — digest janela governada + transfer/capabilities honesty (`c6017af`/`0da9223`); uptime vivo/heal M01 + device ainda A4.2/BLOCKED(server) |
| **Island · Dynamic Island / LA** | Mesma ilha morph: executando → plano → resposta → atenção | `AtlasTurnAttributes` + `TurnPresence` ContentState; timer de `AtlasExecutionPresentationState.Timer`; snapshot App Group | `TurnPresence`; `AtlasActivityAttributes`; `App/Widgets/*` (+`AtlasTurnLockScreen`) | U10 instalado (`c3eda84`); falta print DEVICE_PROVEN | **PARCIAL** — SD-2 + expanded `queueLabel` gold + RM timer (`4191353`/`a45fe54`); lock accessories `LockAccessoryA11y` (`70aec79`); notificação terminal só `Concluído`/`Falhou` (`51e019c`); LA Arena/Fleet + App Intents + DEVICE_PROVEN ainda gap |

### Session Hub (não é cena numerada)

| Alias Fable | Intent | Runtime | Owner | Proof | Gap |
|---|---|---|---|---|---|
| **Session Hub** | Agregar sessões vivas, timers, fase, plano — cockpit na home | `TurnPresence.liveSessions` + `AtlasSession` remote `sessions/live` → `LiveSessionSnapshot` | **`LiveNowSection`** em `RootView` (**deepen**, zero rota) | `AtlasLiveNowTests` + `docs/evidence/2026-07-16-cockpit-v1/` | **PARCIAL** — hub 2+ com spoken «sessão N de M» + timer honesto «—»/RM (`e006511`); prova device multi-session ainda pendente; **proibido** `SessionHubView` |

### Code Radar (não é cena numerada)

| Alias Fable | Intent | Runtime | Owner | Proof | Gap |
|---|---|---|---|---|---|
| **Code Radar** | Status do código; desvios verificados; pastas/repos sem teatro | `AtlasCodeWorkspaceModel` + scan/exceptions via Core | `AtlasCodeRadarView` + `AtlasCodeRadarSections` / rows | device-pending | **PARCIAL** — status «quieto»/alarme só `.violating`; rows/sections a11y + contagens verificadas (`81753f6`); grafo/heal journey + device ainda pendente |

### Arena (fora do teatro 01–13; rota separada)

| Surface | Intent | Runtime | Owner | Proof | Gap |
|---|---|---|---|---|---|
| **Arena** | Medição governada (índice, suites, AGORA, run) — Criação≠Medição | `AtlasArena*` + `ArenaModel` | `AtlasArenaView` + `Arena*Section` / `ArenaRunSheet`; `Route.arena` | `docs/evidence/2026-07-17-arena/` XCUITest enqueue | Worker drain → scoreboard **BLOCKED(server)** A1.2; LA Arena A2; deepen in-app A4.4 |

---

## Legenda de prova

| Valor | Significado |
|---|---|
| **device-pending** | Código/instalação existem; operador ainda não desbloqueou/`passcodeRequired` ou falta print DEVICE_PROVEN (E-A6 / U1–U10) |
| **sim parcial** | XCUITest e/ou evidence em `docs/evidence/*` no simulador ou live-probe — não substitui print físico |
| **EXCLUDED** | Fora do escopo ativo; não gateia A4 |

## Como usar (A4 deepen)

1. Pegar linha com gap ≠ vazio.
2. Confirmar contrato em Core/§5 antes de UI.
3. Aprofundar no **owner** listado — split se view >~200.
4. Prova: CoreChecks + `make build` + XCUITest quando A4.1 exigir + device quando E-A6 abrir.
5. Atualizar esta matriz (append gap→fechado) e OBRA §7.
