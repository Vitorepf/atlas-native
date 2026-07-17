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
| **01 · Atenção necessária** | Sessão pausa de verdade; timer congela na pergunta tipada; ações do servidor; nunca “trabalhando…” falso | `AtlasExecutionPresentationState` (`.attentionRequired` + `timer.paused`); `ConversationModel` projeta `bubble.executionPresentationState`; `choose`/ações do job | `ExecutionStateCard` ← `ConversationChrome` | device-pending (U3/E-A6; `passcodeRequired`) | Card mostra `‖` tempo ativo congelado quando `timer.paused` (paridade Island); permissões tipadas §5 e XCUITest dedicado da pausa ainda device-pending |
| **02 · Replanejamento honesto** | Plano corta/risca passo na frente; “por que mudou”; v1 arquivado; comparar versões | `AtlasExecutionPlan` + `executionProgress`; `AtlasTraceGovernance.planRevisions`; kind `.replanning` no presentation state | `PlanCard` (N/M + “comparar versões”); `ExecutionStateCard` p/ `.replanning` | device-pending | Revisions só com metadata real (`2df3195`); Fable “Session Hub” = metáfora → LiveNow (A4.1). C21 archive completo ainda depende do server |
| **03 · Reconexão sem perda** | Queda → tentativas → resume na seq seguinte; cronômetro não zera | `InteractionRun` (`.reconnecting`); `ConversationModel` → `reconnectNotice`; presentation `.recovering` | `ConversationCockpit` (banner); `ExecutionStateCard` | sim parcial (stream live-probes M06); device físico pendente | Runtime shipado; prova física do timer atravessando queda ainda device-pending |
| **04 · Aguardando sistema externo** | Espera nomeada ≠ pensamento; “pode sair”; lock avisa | `AtlasExecutionPresentationState.awaitingExternal` (+ `deadline` opcional) | `ExecutionStateCard`; fase em `TurnPresence` / Live Activity | device-pending | Kind + copy existem; receipts externos ricos e avanço automático “quando device responde” ainda a contratar / uneven no server |
| **05 · Orquestra de agentes** | Vários agentes mudando estado ao vivo; barra da obra; divergência resolvida | `AtlasAgentActivity` + jobs/`ExecAgent`; `InteractionRun` events; lanes M95 | `LiveTimeline`; `ConversationCockpit`; progress via `executionProgress` | device-pending (cockpit sim Hermes/Kimi em §7 C7/U3) | Parcial: timeline/lanes com 2+ jobs reais; orquestra multi-papel “Investigador/…” da Fable não é cast tipado completo — só o que o ledger publica |
| **06 · Missão noturna** | Madrugada em marcos; resumo ao acordar; Autônomos | `NightlyProposalController` + `AtlasSession` mute; `AutonomosModel` / digest; **não** é sessão de conversa | `NightlyProposalCard` em `AutonomosView` / `RootView`; rota Autônomos | XCUITest `AtlasNightlyProposalTests` + evidence `2026-07-16-proposta-21h/`; device-pending | Proposta das 21h ≠ teatro “missão 23:10→07:30” completo; frota/digest cobrem parte; vertical Autônomos deepen = A4.2 |
| **07 · Revisão entre agentes** | Pareceres por papel; objeção muda implementação; consenso sem raciocínio privado | `AtlasTraceGovernance.councilReview` / `councilDiverged` (metadata); ChangeReview trace | `ChangeReviewSheet` painel council (M10) | device-pending | Council factual na review sheet; **C20 `agentVerdicts`/consensus** da cena Fable ainda aberto em A3.3 — não inventar votos |
| **08 · Continuidade entre devices** | Handoff iPhone↔Mac/Terminal; mesma thread; zero prompt duplicado | `ConversationModel+Continuity.handoffToSurface`; `AtlasAiSurfaceDestination`; recibo `latestSurfaceHandoff` | Menu continuidade + `handoffReceipt` em `ConversationView`; LiveNow badge remoto (`sessions/live`) | device-pending | Recibo ready/pending + `createdAt` relativo + «sem prompt duplicado» + A11yID; theater multi-device/deep-link ainda device-pending; **não** vira Session Hub route |
| **09 · Voz contínua** | Ouvindo → respondendo → executando (ilha) | — | — | — | **EXCLUDED** — Voice vertical futura (OBRA §4 aviso + Elite constraints). Zero trabalho nesta matriz |
| **10 · Artefato pronto** | Entrega monta com checks; ações só após prova | `AtlasTraceArtifacts` via `ChangeReviewModel.refreshArtifacts`; quality no cockpit | `ArtifactSheet`; linha em `ConversationChrome` / `ExecutionStateCard` completed | evidence `2026-07-16-artifacts/`; device/live token pendentes | Sheet + manifesto trace-scoped shipados; montagem animada “checks 0/3→3/3” da Fable é parcial; prova iPhone real pendente |
| **11 · Fila durante a execução** | Send durante turno → fila; chip N; promote/remove; FIFO drena | `QueuedFollowUpStore` / `AtlasQueuedFollowUp`; `ConversationModel.queuedMessages` + `queue`/`promote`/`removeQueued` | Chip + sheet em `ConversationView` | sem XCUITest promote/remove/FIFO dedicado; device-pending | Runtime C11 ligado; **A4.1 pede prova XCUITest** da fila — ainda gap |
| **12 · Revisar mudanças** | Diff vivo; aceitar/rejeitar por arquivo/run; ledger | `AtlasChangeReview` / `ChangeReviewModel` (C15/C16) | `ChangeReviewSheet` (`ChangeReviewView.swift`) | device-pending; falta trace real + print | Casca ligada; prova física e journey E2E com patch real ainda abertas (C15/C16 → Fable) |
| **13 · Falha honesta do turno** | Falha nomeada + motivo + Retomar do checkpoint | `.failed` + `checkpoint` em presentation state; `retryableJobId` / C17 retry | `ExecutionStateCard` (“Retomar”) | device-pending | Card + retry reais quando contrato/job permitem; “Diagnóstico” rico e resume seq exata dependem do server declarar ações/checkpoint |
| **Fleet · Command Center** | Frota viva: uptimes, heartbeats, lease/atenção, transferir c/ prova, digest 14:00 | `AtlasAutonomos*` via `AutonomosModel` (fleet, digest, transfer, history, live) | `AutonomosView` (+ sheets); widgets frota leem `AtlasNativeSnapshot.fleet` | sim parcial Autônomos/Nightly; device-pending; heal→merge M01 BLOCKED(server) | Superfície própria OK; digest último resumo mostra janela governada (`hours`+`endedAt`) quando servidor publica; fidelidade uptime vivo/transfer UI = A4.2; split monólito pendente B1 |
| **Island · Dynamic Island / LA** | Mesma ilha morph: executando → plano → resposta → atenção | `AtlasTurnAttributes` + `TurnPresence` ContentState; timer de `AtlasExecutionPresentationState.Timer`; snapshot App Group | `TurnPresence`; `AtlasActivityAttributes`; `App/Widgets/*` (+`AtlasTurnLockScreen`) | U10 instalado (`c3eda84`); falta print DEVICE_PROVEN | SD-2 turn: ATT/EXT/FAIL/REC/PLN + N/M + fila a partir de phaseTitle/progress/queued (**4191353**); LA Arena/Fleet + App Intents M89 ainda gaps; prova física pendente |

### Session Hub (não é cena numerada)

| Alias Fable | Intent | Runtime | Owner | Proof | Gap |
|---|---|---|---|---|---|
| **Session Hub** | Agregar sessões vivas, timers, fase, plano — cockpit na home | `TurnPresence.liveSessions` + `AtlasSession` remote `sessions/live` → `LiveSessionSnapshot` | **`LiveNowSection`** em `RootView` (**deepen**, zero rota) | `AtlasLiveNowTests` + `docs/evidence/2026-07-16-cockpit-v1/` | A4.1 hub 2+ rows (title/phase/timing/elapsed) DONE; plan N/M já via `phaseTitle` do TurnPresence; prova device multi-session ainda pendente; **proibido** `SessionHubView` |

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
