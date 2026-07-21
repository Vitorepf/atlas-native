# Atlas Native — CODEMAP (casca)

> Mapa curto para IA. Manter verdadeiro. Grok B atualiza após W3 / idle que mude topologia.  
> Canon: `docs/prompts/grok-god-code-canon.md`

## Superfícies → entrada

| Superfície | Entry / shell | Núcleo vivo (não exaustivo) |
|---|---|---|
| Home | `RootView.swift` | `RootChrome*`, `RootHome*`, `Workspace*` |
| Conversa | `ConversationView.swift` | `ConversationSurface (+Composer/+Chrome peels)`, `ConversationChrome*`, Messages/Cockpit/Composer* |
| Código | `AtlasCodeView.swift` | `AtlasCodeSurface`, Radar*, Graph*, CommitRow*, Provenance* |
| Radar (multi-repo) | `AtlasCodeRadarView.swift` | Surface · FolderRow · RepoChrome · AskContext · Judgment |
| Pílula | (dock por superfície) | `AgenticPill`, `AgenticOccasionPack`, `AgenticAskDock` |
| Arena Premium | `ArenaPremiumShell.swift` | Execution/Fleet/Results/Suite/Run/Score* |
| Autônomos | `AutonomosHubView.swift` / `AutonomosView.swift` | Hub/Map/List/`AutonomosDecision*`/Chrome* |
| Continuity | Widgets + ActivityKit | Island/Lock chrome — **App Group data BLOCKED** |

## Onde muda X

| Intenção | Comece em |
|---|---|
| Ordem/julgamento frota Radar | `AtlasCodeRadarJudgment` → Rows/View |
| **Radar screen load (frota)** | `AtlasCodeRadarScreenJudgment` → face loading/failed/empty/ready · shell a11y · pack Ask (WAVE-162) |
| Grafo single-repo judgment (fatia default) | `AtlasCodeGraphJudgment` → filter chips / list / pack |
| **Grafo worktrees** | `AtlasCodeWorktreeJudgment` → section silence/list(N) · rank dirty-first · pack |
| Código grafo peels | `AtlasCodeSurface` host · `AtlasCodeSurfaceGraph` content/list |
| **Grafo chrome (status/filtros/worktrees/semana)** | `AtlasCodeGraphChrome` status · `FilterChrome` · `WorktreeChrome` · `WeekChrome` (WAVE-156) |
| **Grafo screen load (Código)** | `AtlasCodeGraphScreenJudgment` → face loading/failed/empty/ready · screen a11y · pack in CodeAsk (WAVE-161) |
| **Pílula ask (Código)** | `AtlasCodeAskPillJudgment` → face invite/anchoring/legend · AskContext pack |
| **Repo health (scan·heal·week·mirror)** | `AtlasCodeRepoHealthJudgment` → HealthStrip · Ask pack face |
| **Heal veto / undoError** | `AtlasCodeHealVetoJudgment` → ReceiptSheet · canVeto · undo fail line |
| **Commit row face (grafo)** | `AtlasCodeCommitRowJudgment` → dim/fora/main · pack CodeAsk focus (WAVE-167) |
| Commit row peels | `AtlasCodeCommitRowBody` · spoken via `AtlasCodeCommitRowJudgment` |
| **Why biografia arquivo (H1)** | `AtlasCodeWhyJudgment` → face · pack API CodeAsk (WAVE-167) |
| **Proveniência do commit** | `AtlasCodeProvenanceJudgment` → face · pack CodeAsk focus (WAVE-167) |
| Pack da pílula / ocasião | `AgenticOccasionPack` + hosts Ask |
| Pack mid-thread conversa | `ConversationOccasionPack` (nunca `HomeAskContext` em `.thread`) |
| Workspace/Search live-first list | `WorkspaceThreadJudgment` → rank + ThreadRow threadId running |
| **Search screen (shell)** | `SearchScreenJudgment` → face loading/offline/empty/results · screen a11y |
| **Search list/row** | `SearchListJudgment` → list recent/results/miss · captions · row · miss headline |
| **Workspace screen (lista)** | `WorkspaceScreenJudgment` → face loading/offline/empty/list · screen a11y · pack Ask (WAVE-162) |
| **Workspace picker (sheet)** | `WorkspacePickerJudgment` → face loading/failed/empty/list/miss · rank · pack |
| **Workspace empty editorial** | `WorkspaceEmptyJudgment` → face area/free/workspace · glyph empty |
| **Ops failure (multi-superfície)** | `AtlasOpsFailureJudgment` → face network/domain/load · FailureEmpty |
| Phase grammar execução (strip/presence) | `ConversationExecutionPhase` → strip/StateCard/LiveNow/composer `selectPresenceBubble` |
| **Execution proof + editorial pack (165)** | `ExecutionProofJudgment` · `EditorialTurnJudgment` → OccasionPack mid-thread |
| **LiveNow attention (Home hub)** | `LiveNowJudgment` → rank · headForOpen (Seguir) · pack anchors · section face |
| **StateCard kind chrome** | `ExecutionStateCardJudgment` → icon/badge/spoken/tint/timer freeze |
| **Narrativa viva (timeline face)** | `LiveTimelineNarrativeJudgment` → face live/filterSilence (chrono sagrado) |
| **Filtro de leitura (timeline)** | `LiveTimelineFilterJudgment` → face open/active/silent · chip/silence spoken |
| Timeline filter peels | `LiveTimelineFilterChrome` (ReadFilter + FilterChips) |
| **Continuidade handoff (iPhone↔Mac)** | `ConversationHandoffJudgment` → receipt face ready/pending/other · pack mid-thread (WAVE-161) |
| **Composer send readiness** | `ComposerSendJudgment` → face ready/blocked/queue · gold gate · draft rank |
| **Composer draft/anexos** | `ComposerDraftJudgment` → strip · DraftStrip · pack mid-thread (WAVE-164) |
| **Composer toolbar chrome** | `ComposerToolbarJudgment` → attach/options/mode/workspace spoken · pack |
| **Composer esforço** | `ComposerEffortJudgment` → face · pack mid-thread (WAVE-164) |
| **Composer folhas modo/workspace** | `ComposerSheetJudgment` → mode face · workspace sheet empty/list |
| Composer sheet peels | `ComposerSheetPrimitives` (EffortSheet · SheetRow · NewMarker) · SheetsHost |
| **Composer fila (head FIFO)** | `ComposerQueueJudgment` → chip head snippet · sheet spoken · pack |
| **Stale-read cache seal** | `ConversationStaleReadJudgment` → face · pack mid-thread (WAVE-164) |
| **Messages surface (lista)** | `ConversationMessagesJudgment` → face · pack mid-thread (WAVE-168) |
| Messages peels | `ConversationMessages` host · `ConversationMessagesScroll` · `ConversationMessagesEditorial` |
| **Empty editorial (partida)** | `ConversationEmptyJudgment` → face silence/default_prompt/custom_prompt/suggestions(N) · EmptyStates |
| **Índice da conversa (outline)** | `ConversationOutlineJudgment` → face empty/turns · sheet · pack mid-thread (WAVE-166) |
| **Home OPERAÇÃO attention** | `HomeOpsJudgment` → Autônomos door face · Arena door · pack |
| **Partida can_do (Home/WS/Radar)** | `PartidaCanDoJudgment` → HomeAskContext · WorkspaceAskContext · RadarAskContext (WAVE-158) |
| **Autônomos can_do honesty** | `AutonomosCanDoJudgment` → matrix dest×control×canControl · AskContext pack |
| **Autônomos lista/row** | `AutonomosListJudgment` → list empty/list(N) · row awaiting/live/quiet · pack |
| **Autônomos hub** | `AutonomosHubJudgment` → hubFace · spokenHub · receiptTone · pack Ask .hub (WAVE-162) |
| **Autônomos razão governada** | `AutonomosReasonJudgment` → face blocked/ready · ReasonSheet |
| Presence primary chrome (face lead) | `ConversationExecutionPhase.primarySpoken` + `selectPresenceBubble` · dual-surface 012 |
| **Turn presence pack (168)** | `TurnPresenceJudgment.packFacts` → OccasionPack mid-thread |
| Conversation mid-run **Escolher** | `ConversationDecisionJudgment` → ExecutingStrip → `resolveExecutionChoice` |
| **Live strip peels** | `ConversationCockpitAgentRow` host · `StripStatus` · `StripActions` (WAVE-156) |
| **Live strip CTAs** | `ConversationLiveStripJudgment` → stop/steer/choose spoken · compound strip · pack |
| **Conversation can_do pack** | `ConversationCanDoJudgment` → matrix live×decision · OccasionPack wire |
| Cockpit peels | `ConversationCockpitBody` (strip·lanes) · `ConversationCockpitBanners` (banner·reconnect·silence) |
| **Steer / redirecionar** | `ConversationSteerJudgment` → receipt face · scope PT · allowsSubmit |
| **Steer pack mid-thread (160)** | OccasionPack → `ConversationSteerJudgment.packFacts` + strip stop honesty |
| **Agent lanes (multi)** | `ConversationAgentLanesJudgment` → ExecutionRibbon rank failed-first |
| Island/Lock phase chrome | Widgets Live/Lock* (sem inventar App Group) |
| Score/julgamento Arena | `ArenaScoreJudgment` + Suite/Run sheets |
| **Arena capacidades (confiança)** | `ArenaCapabilitiesJudgment` → measured/improved/regressed one law · rank · pack |
| **Arena agora (fase)** | `ArenaNowJudgment` → face idle/queued/running/terminal · NowStates chrome |
| **Arena pack can_do honesty** | AskContext wires Now+LiveControl packFacts · canDo matrix · canStop one law |
| **Arena organ pack wire (157)** | AskContext → Stop/Pipeline/Start/RunStatus packFacts · RunStatus productWord · `ArenaFleetJudgment` rank≡FleetView |
| **Arena plano/fila** | `ArenaPlanQueueJudgment` → planFace empty/published/derived_live · queueFace |
| **Arena live control (corridas)** | `ArenaLiveControlJudgment` → rank · face · canStop |
| **Arena start / recibo rodar** | `ArenaStartJudgment` → submit face · receipt face · worker gap |
| **Arena run sheet (shell)** | `ArenaRunSheetJudgment` → face empty_engines/empty_suites/ready · pack Ask (WAVE-166) |
| **Arena suite drill** | `ArenaSuiteJudgment` → rank regressed-first · suite face · pack Ask (WAVE-166) |
| **Decisão Autônomos (julgar + assinar)** | `AutonomosDecisionJudgment` → `AutonomosDecisionSurface` → Hub CTA / MapShell `.decisions` / `AutonomosModel.decide` |
| **Decisão surface peels** | host · `ListBody` · `DetailBody` · `Sections` (WAVE-156) |
| **MapShell peels** | host sheets · `Routes` · `Ask` · `Catalog` · `Actions` (WAVE-156) |
| **Controle do loop Autônomos (veto)** | `AutonomosRunControlJudgment` → Hub primaryVerb → ReasonSheet → `model.control` / `startRun` · bind `selectArea` |
| **Multi-área bind (chooser)** | `AutonomosAreaBindJudgment` → face none/auto/needs_bind/bound · `AutonomosAreaBindChooser` · Hub CTA |
| **Proposta noturna** | `NightlyProposalJudgment` → face pending/muted/muted_auto/hidden · Block/Card/Rhythm |
| **Nightly schedule peel** | `NightlyProposalController` host · `NightlyProposalSchedule` (WAVE-156) |
| **Ritmo do dia (aprender)** | `AutonomosRhythmJudgment` → face learning/learned/paused · line/sheet |
| **Veto retroativo self-construction** | `SelfConstructionVetoJudgment` → ReceiptSheet canRevert → `model.revertCycle` |
| **Veto + nightly pack (159)** | `SelfConstructionVetoJudgment.packFacts` · Nightly pack on catalog · can_do canRevert → AskContext |
| **Evolução / entregas Autônomos** | `AutonomosEvolutionJudgment` → EvolutionView marcos → receipt |
| **Transfer handoff missão** | `AutonomosTransferJudgment` → Hub CTA → ReasonSheet → `model.transfer` |
| **Task health / incidente frota** | `AutonomosTaskHealthJudgment` → IncidentSurface · vestment incidentPresent |
| **Frota global (agentes vivos)** | `AutonomosFleetJudgment` → FleetStrip no catálogo |
| **Digest / momento (janela)** | `AutonomosDigestJudgment` → DigestSurface · `.moment("digest")` |
| **Change review risk (achados/patches)** | `ChangeReviewJudgment` → RiskStrip + FindingsBody/PatchBody · sheet spoken · pack mid-thread (WAVE-163) |
| **Change review governance chrome** | `ChangeReviewJudgment` spokenCouncil/DiffStats/hash · packGovernanceFacts → GovernanceBody |
| **Change review sheet load** | `ChangeReviewSheetJudgment` → face loading/unavailable/empty/ready |
| Change review peels | Sections host · Judgment section spoken · GovernanceBody · Patch/Run/Findings |
| **Plan progresso (card + cockpit)** | `PlanJudgment` → face/spoken card/detail/chip/revision · PlanFaceStrip |
| Plan card peels | `PlanCard` host · `PlanCardRevisionBody` · `PlanCardStepRow` |
| **Artefatos / evidência do turno** | `ArtifactJudgment` → FaceStrip · kind rank · delivery fail-first |
| **Preview de artefato** | `ArtifactPreviewJudgment` → face idle/load/loaded/tooLarge/failed · viewer spoken/zoom |
| Artifact sheet peels | `ArtifactSheet` host/list · `+Chrome` · `+Preview` · Delivery |
| Preview peels | `ArtifactPreviewChrome` host · `TraceEvidenceChrome` · `ArtifactPreviewZoom` (Judgment-only a11y) |
| **Provenance file-row spoken** | `AtlasCodeProvenanceJudgment` spokenFile/verb/packFile → FileRow |
| **Trace evidence chrome** | `TraceEvidenceJudgment` → loading/unavailable · reason honesty · Loading/Unavailable views |
| **Turn presence away notify** | `TurnPresenceJudgment` isTerminal/title/body/spoken · TurnPresence host |
| **Prova de execução (card recolhido)** | `ExecutionProofJudgment` · peels Chrome/host/Sections (WAVE-113) |
| **Artefatos lista/row** | `ArtifactListJudgment` → list silence/list(N) · row · empty visualizable · close |
| **Assinatura editorial (turno)** | `EditorialTurnJudgment` → signature present/absent · feedback spoken · pack |
| EditorialTurn peels | `EditorialTurn` host · `EditorialTurnChrome` (FeedbackRow · SignatureLine) |
| **Markdown blocks spoken** | `AtlasMarkdownJudgment` list/quote/code/copy · Surface/Blocks |
| **Autônomos/Home residual spoken** | Digest/Evolution/Hub/Decision + HomeOps profile (WAVE-104) |
| **Mid-thread pack hydration** | `ConversationOccasionPack.PublishedSlice` + model.turnFacts rebind (WAVE-106) |
| **Arena run status chrome** | `ArenaRunStatusJudgment` label/tone/glyph/trailing · Execution/Detail/Icon (WAVE-107) |
| **Arena stop governance** | `ArenaStopJudgment` face blocked/ready · StopSheet (WAVE-108) |
| **Arena execution pipeline** | `ArenaPipelineJudgment` project/glyph/spoken · ExecutionPipeline (WAVE-109) |
| **LiveNow row spoken** | `LiveNowJudgment` spokenRow/clock · LiveNowRow (WAVE-110) |
| **Artifact sheet peels** | host/list · Chrome · Preview · Delivery (WAVE-112) |
| **Radar rows peels** | FolderRow · RepoChrome · AskContext (WAVE-114) |
| **Root chrome routes peels** | Face · ConversationRoutes · Lifecycle (WAVE-115) |
| **TurnPresence peels** | host · Activity · Runtime (WAVE-116) |
| **LiveTimeline peels** | host · NarrativeRow · NarrativeRowView (WAVE-117) |
| **Commit row peels** | Body · Meta (WAVE-118) |
| **Conversation sheets peels** | SheetsBody · ComposerSheetsModifier (WAVE-119) |
| **Search surface peels** | Surface/Header · Results (WAVE-120) |
| **Plan card peels** | PlanCard host · PlanCardBody (WAVE-121) |
| **Workspace surface peels** | Surface · Body/threads (WAVE-122) |
| **Composer toolbar peels** | Chrome · ChromeBody (WAVE-123) |
| **Provenance sections peels** | Sections · SectionsBody (WAVE-124) |
| **Surface graph peels** | Graph · GraphBody (WAVE-125) |
| **ArenaRunSheet peels** | host · Body (WAVE-126) |
| **ExecutionStateCard peels** | host · Body (WAVE-127) |
| **AutonomosView peels** | View · Header (WAVE-128) |
| **ChangeReview patch peels** | PatchBody · DiffViewBody (WAVE-129) |
| **Markdown blocks peels** | Blocks · ViewBlocks (WAVE-130) |
| **A11yID domain peels** | core · Arena · Code · Autonomos (WAVE-131) |
| **ChangeReview Judgment peels** | core · Chrome spoken (WAVE-132) |
| **SelfConstruction receipt peels** | Body · Chrome (WAVE-134) |
| **Root home sections peels** | Body · Live (WAVE-135) |
| **LiveTimeline narrative peels** | RowView · Chrome (WAVE-136) |
| **AutonomosDecision Judgment peels** | core · Grammar (WAVE-137) |
| **ArenaModel peels** | host · Actions (WAVE-138) |
| **AutonomosModel peels** | host · Actions (WAVE-139) |
| **ChangeReview governance peels** | Body · Chrome (WAVE-140) |
| **Code sheets modifiers peels** | Modifiers · Body (WAVE-141) |
| **AtlasSession peels** | host · Body (WAVE-142) |
| **Code surface peels** | Surface · Body (WAVE-143) |
| **ExecutionProof Judgment peels** | core · Chrome (WAVE-144) |
| **PlanJudgment peels** | core · Chrome (WAVE-145) |
| **LiveNowJudgment peels** | core · Row (WAVE-146) |
| **ComposerDraftJudgment peels** | core · Attach (WAVE-147) |
| **ChangeReview sections peels** | Sections · SectionsBody (WAVE-148) |
| **ArenaSuiteSheet peels** | Sheet · Body (WAVE-149) |
| **RootChrome peels** | Chrome · Body (WAVE-150) |
| **ExecutionStateCardSpoken peels** | Spoken · Body (WAVE-151) |
| **Composer sheets modifier peels** | Modifier · Body (WAVE-152) |
| **ExecutionProof sections peels** | Sections · Body (WAVE-153) |
| **Markdown view blocks peels** | ViewBlocks · Body (WAVE-154) |
| **SelfConstruction chrome peels** | Chrome · Peel (WAVE-155) |
| Design tokens | `AtlasTheme` / `AtlasType` / `AtlasMotion` |

## BLOCKED (honesto)

- App Group / Fleet·CodeWeek widget **data** restore  
- Core novos campos / endpoints (`Sources/**`, ConversationModel lógica)  
- Device proof sem passcode do operador  

## Densidade (lembrete)

View/Shell rota ≤600 · Surface 1 domínio ≤1500 (fail &gt;2000) · um domínio por arquivo.
