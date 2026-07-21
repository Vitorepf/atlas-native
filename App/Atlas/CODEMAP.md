# Atlas Native — CODEMAP (casca)

> Mapa curto para IA. Manter verdadeiro. Atualizar após idle/restructure que mude topologia. 
> Canon: `docs/prompts/grok-god-code-canon.md` · navegação = `Type.method` (sem id de wave)

## Superfícies → entrada

| Superfície | Entry / shell | Núcleo vivo (não exaustivo) |
|---|---|---|
| Home | `RootView.swift` | `RootChrome`, `RootHomeBody`, `Workspace*` |
| Conversa | `ConversationView.swift` | `ConversationSurface fused`, `ConversationChrome*`, Messages/Cockpit/Composer* |
| Código | `AtlasCodeView.swift` | `AtlasCodeSurface`, Radar*, Graph*, CommitRow*, Provenance* |
| Radar (multi-repo) | `AtlasCodeRadarView.swift` | Surface · FolderRow · RepoChrome · AskContext · Judgment |
| Pílula | (dock por superfície) | `AgenticPill`, `AgenticPill`, `AgenticPill` |
| Arena Premium | `ArenaPremiumShell.swift` | Execution/Fleet/Results/Suite/Run/Score* · NowBody · GlyphRow |
| Autônomos | `AutonomosHubView.swift` / `AutonomosView.swift` | Hub/Map/List/`AutonomosDecision*`/Chrome* |
| Continuity | Widgets + ActivityKit | Island/Lock chrome — **App Group data BLOCKED** |

## Onde muda X

| Intenção | Comece em |
|---|---|
| Ordem/julgamento frota Radar | `AtlasCodeRadarJudgment` → Rows/View · pack attention · pack workspace shell |
| **LiveNow pack (Home)** | `LiveNowJudgment.packFacts` · HomeAsk · packHubFacts Workspace |
| **Arena shell pack** | `ArenaPremiumAskContext.packShellFacts` · tela/aba/cobertura |
| **Radar screen load (frota)** | `AtlasCodeRadarLoadJudgment` → face loading/failed/empty/ready · shell a11y · pack Ask |
| Grafo single-repo judgment (fatia default) | `AtlasCodeGraphJudgment` → filter chips / list / pack · packIdentityFacts |
| **Arena live measurement pack** | `ArenaLiveControlJudgment.packMeasurementFacts` → progress/alerts/narrative/list |
| **Grafo worktrees** | `AtlasCodeWorktreeJudgment` → section silence/list(N) · rank dirty-first · pack |
| Código grafo parts | `AtlasCodeSurface` host · `AtlasCodeSurfaceGraph` content/list |
| **Grafo chrome (status/filtros/worktrees/semana)** | `AtlasCodeGraphChrome` status·filter·worktree·week (fused) |
| **Grafo screen load (Código)** | `AtlasCodeGraphLoadJudgment` → face loading/failed/empty/ready · screen a11y · pack in CodeAsk |
| **Pílula ask (Código)** | `AtlasCodeAskPillJudgment` → face invite/anchoring/legend · AskContext pack |
| **Repo health (scan·heal·week·mirror)** | `AtlasCodeRepoHealthJudgment` → HealthStrip · Ask pack face |
| **Heal veto / undoError** | `AtlasCodeHealVetoJudgment` → ReceiptSheet · canVeto · undo fail line |
| **Commit row face (grafo)** | `AtlasCodeCommitRowJudgment` → dim/fora/main · pack CodeAsk focus |
| Commit row parts | `AtlasCodeCommitRowBody` · spoken via `AtlasCodeCommitRowJudgment` |
| **Why biografia arquivo (H1)** | `AtlasCodeWhyJudgment` → face · pack API CodeAsk |
| **Proveniência do commit** | `AtlasCodeProvenanceJudgment` → face · pack CodeAsk focus |
| Pack da pílula / ocasião | `AgenticPill` + hosts Ask |
| Pack mid-thread conversa | `ConversationOccasionPack` host · Live · Organs parts · thread shell Judgment |
| **Conversation thread shell** | `ConversationThreadShellJudgment.packFacts` → thread/title/workspace binding |
| **Workspace catalog shell pack** | `WorkspaceThreadJudgment.packShellFacts` → WorkspaceAsk |
| Workspace/Search live-first list | `WorkspaceThreadJudgment` → rank + ThreadRow threadId running |
| **Search screen (shell)** | `SearchJudgment` → face loading/offline/empty/results · screen a11y · pack |
| **Search list/row** | `SearchListJudgment` → list recent/results/miss · captions · row · miss headline |
| **Search pílula / pack** | `SearchAskContext` + `SearchView` AgenticPill · PartidaCanDo.search |
| **Workspace screen (lista)** | `WorkspaceJudgment` → face loading/offline/empty/list · screen a11y · pack Ask |
| **Workspace picker (sheet)** | `WorkspacePickerJudgment` → face · pack Home partida |
| **Workspace empty editorial** | `WorkspaceEmptyJudgment` → face · `WorkspaceEmptyChrome` glyph/loading/network empty |
| **Ops failure (multi-superfície)** | `AtlasOpsFailureJudgment` → face network/domain/load · FailureEmpty |
| Phase execução (strip/presence) | `ConversationExecutionPhase` → strip/StateCard/LiveNow/composer `selectPresenceBubble` |
| **Execution proof + editorial pack** | `ExecutionProofJudgment` · `EditorialTurnJudgment` → OccasionPack mid-thread |
| **LiveNow attention (Home hub)** | `LiveNowJudgment` → rank · headForOpen (Seguir) · packFacts · section face |
| **StateCard kind chrome** | `ExecutionStateCardJudgment` → icon/badge/spoken/tint/timer freeze · pack mid-thread |
| **Narrativa viva (timeline face)** | `LiveTimelineNarrativeJudgment` → face live/filterSilence (chrono sagrado) · pack mid-thread |
| **Filtro de leitura (timeline)** | `LiveTimelineFilterJudgment` → face open/active/silent · chip/silence spoken · pack open recorte |
| **Markdown block kinds (pack)** | `AtlasMarkdownJudgment.packFacts(from:)` → list\|quote\|code mid-thread |
| Timeline filter parts | `LiveTimelineFilterChrome` (ReadFilter + FilterChips) |
| **Continuidade handoff (iPhone↔Mac)** | `ConversationHandoffJudgment` (receipt fused) → face ready/pending/other · pack mid-thread |
| **Composer send readiness** | `ComposerSendJudgment` → face ready/blocked/queue · gold gate · draft rank · pack mid-thread |
| **Composer draft/anexos** | `ComposerDraftJudgment` → strip · DraftStrip · pack mid-thread |
| **Composer toolbar** | `ComposerToolbarJudgment` → attach/options/mode/workspace spoken · pack |
| **Composer esforço** | `ComposerEffortJudgment` → face · pack mid-thread |
| **Composer folhas modo/workspace** | `ComposerSheetJudgment` → mode face · workspace sheet empty/list |
| Composer sheet parts | `ComposerSheetPrimitives` (EffortSheet · SheetRow · NewMarker) · SheetsHost |
| **Composer fila (head FIFO)** | `ComposerQueueJudgment` → chip head snippet · sheet spoken · pack |
| **Stale-read cache seal** | `ConversationStaleReadJudgment` (seal chrome fused) → face · pack mid-thread |
| **Messages surface (lista)** | `ConversationMessagesJudgment` → face · pack mid-thread |
| Messages parts | `ConversationMessages` host (scroll·editorial fused) · Judgment |
| **Empty editorial (partida)** | `ConversationEmptyJudgment` → face · `EmptyConversation` chrome |
| **Índice da conversa (outline)** | `ConversationOutlineJudgment` (sheet fused) → face empty/turns · pack mid-thread |
| **Home OPERAÇÃO attention** | `HomeOpsJudgment` → Autônomos door face · Arena door · pack · packCatalogFacts |
| **Autônomos unit focus pack** | `AutonomosListJudgment.packUnitFocusFacts` → Ask host |
| **Partida can_do (Home/WS/Radar)** | `PartidaCanDoJudgment` → HomeAskContext · WorkspaceAskContext · RadarAskContext |
| **Autônomos can_do honesty** | `AutonomosCanDoJudgment` → matrix dest×control×canControl · AskContext pack |
| **Autônomos lista/row** | `AutonomosListJudgment` → list empty/list(N) · row awaiting/live/quiet · pack |
| **Autônomos hub** | `AutonomosHubJudgment` → hubFace · spokenHub · receiptTone · pack Ask .hub |
| **Autônomos razão governada** | `AutonomosReasonJudgment` → face · ReasonSheet · pack when canControl |
| Presence primary chrome (face lead) | `ConversationExecutionPhase.primarySpoken` + `selectPresenceBubble` |
| **Turn presence pack** | `TurnPresenceJudgment.packFacts` → OccasionPack mid-thread |
| Conversation mid-run **Escolher** | `ConversationDecisionJudgment` → ExecutingStrip → `resolveExecutionChoice` |
| **Live strip parts** | `ConversationCockpitStrip` (ExecutingStrip) · `ConversationCockpitAgentRow` · Banners |
| **Live strip CTAs** | `ConversationLiveStripJudgment` → stop/steer/choose spoken · compound strip · pack |
| **Conversation can_do pack** | `ConversationCanDoJudgment` → matrix live×decision · OccasionPack wire |
| Cockpit parts | `ConversationCockpitStrip` · `ConversationCockpitAgentRow` · `ConversationCockpitBanners` |
| **Steer / redirecionar** | `ConversationSteerJudgment` → receipt face · scope PT · allowsSubmit |
| **Steer pack mid-thread** | OccasionPack → `ConversationSteerJudgment.packFacts` + strip stop honesty |
| **Agent lanes (multi)** | `ConversationAgentLanesJudgment` → ExecutionRibbon rank failed-first |
| Island/Lock phase chrome | `AtlasTurnGlanceJudgment` · Widgets Live/Lock* (sem inventar App Group) |
| Score/julgamento Arena | `ArenaScoreJudgment` + Suite/Run sheets · pack primary engine |
| **Arena capacidades (confiança)** | `ArenaCapabilitiesJudgment` → measured/improved/regressed one law · rank · pack |
| **Arena agora (fase)** | `ArenaNowJudgment` → face idle/queued/running/terminal · `ArenaPremiumNowBody` |
| **Arena pack can_do honesty** | `ArenaPremiumAskContext` host · Live/Score organs fused · canDo matrix |
| **Arena organ pack wire** | AskContext → Stop/Pipeline/Start/RunStatus packFacts · RunStatus productWord · `ArenaFleetJudgment` rank≡FleetView |
| **Arena plano/fila** | `ArenaPlanQueueJudgment` → planFace empty/published/derived_live · queueFace |
| **Arena live control (corridas)** | `ArenaLiveControlJudgment` → rank · face · canStop |
| **Arena start / recibo rodar** | `ArenaStartJudgment` → submit face · receipt face · worker gap |
| **Arena run sheet (shell)** | `ArenaRunSheetJudgment` → face empty_engines/empty_suites/ready · pack Ask |
| **Arena suite drill** | `ArenaSuiteJudgment` → rank regressed-first · suite face · pack Ask |
| **Decisão Autônomos (julgar + assinar)** | `AutonomosDecisionJudgment` → `AutonomosDecisionSurface` · `AutonomosDecisionFaceBody` → Hub/Map · pack face |
| **Decisão surface parts** | `AutonomosDecisionSurface` (face·list·detail fused) |
| **MapShell parts** | host sheets · `Routes` · `Ask` · `Catalog` · `Actions` |
| **Controle do loop Autônomos (veto)** | `AutonomosRunControlJudgment` → Hub primaryVerb → ReasonSheet → `model.control` / `startRun` · bind `selectArea` |
| **Multi-área bind (chooser)** | `AutonomosAreaBindJudgment` → face none/auto/needs_bind/bound · `AutonomosAreaBindChooser` · Hub CTA |
| **Proposta noturna** | `NightlyProposalJudgment` → face pending/muted/muted_auto/hidden · Block/Card/Rhythm |
| **Nightly schedule** | `NightlyProposal` host (controller·block·schedule fused) |
| **Ritmo do dia (aprender)** | `AutonomosRhythmJudgment` → face learning/learned/paused · line/sheet · pack Ask catalog |
| **Veto retroativo self-construction** | `SelfConstructionVetoJudgment` → ReceiptSheet canRevert → `model.revertCycle` |
| **Veto + nightly pack** | `SelfConstructionVetoJudgment.packFacts` · Nightly pack on catalog · can_do canRevert → AskContext |
| **Evolução / entregas Autônomos** | `AutonomosEvolutionJudgment` → EvolutionView marcos → receipt |
| **Transfer handoff missão** | `AutonomosTransferJudgment` → Hub CTA → ReasonSheet → `model.transfer` |
| **Task health / incidente frota** | `AutonomosTaskHealthJudgment` → IncidentSurface · vestment incidentPresent |
| **Frota global (agentes vivos)** | `AutonomosFleetJudgment` → FleetStrip no catálogo |
| **Digest / momento (janela)** | `AutonomosDigestJudgment` → DigestSurface · `.moment("digest")` |
| **Change review risk (achados/patches)** | `ChangeReviewJudgment` → RiskStrip + FindingsBody/PatchBody · sheet spoken · pack mid-thread |
| **Change review assinatura (accept/reject)** | `ChangeReviewControlJudgment` → availableActions · file undecided · can_do faceCTALocal |
| **Change review governance chrome** | `ChangeReviewJudgment` spokenCouncil/DiffStats/hash · packGovernanceFacts → GovernanceBody |
| **Change review sheet load** | `ChangeReviewSheetJudgment` → face loading/unavailable/empty/ready |
| Change review parts | Sections host · Judgment section spoken · GovernanceBody · Patch/Run/Findings |
| **Plan progresso (card + cockpit)** | `PlanJudgment` → face/spoken card/detail/chip/revision · PlanFaceStrip |
| Plan card parts | `PlanCard` host · `PlanRevisionCompare` (archive·a11y fused) · `PlanCardStepRow` |
| **Artefatos / evidência do turno** | `ArtifactJudgment` → FaceStrip · kind rank · delivery fail-first |
| **Preview de artefato** | `ArtifactPreviewJudgment` → face idle/load/loaded/tooLarge/failed · viewer spoken/zoom |
| Artifact sheet parts | `ArtifactSheet` host/list · `+Chrome` · `+Preview` · Delivery |
| Preview parts | `ArtifactPreviewChrome` host · `TraceEvidenceChrome` · `ArtifactPreviewZoom` (Judgment-only a11y) |
| **Provenance file-row spoken** | `AtlasCodeProvenanceJudgment` spokenFile/verb/packFile → FileRow |
| **Trace evidence chrome** | `TraceEvidenceJudgment` → loading/unavailable · reason honesty · Loading/Unavailable views |
| **Turn presence away notify** | `TurnPresenceJudgment` isTerminal/title/body/spoken · TurnPresence host |
| **Prova de execução (card recolhido)** | `ExecutionProofJudgment` · host · Chrome · `ExecutionProof` |
| **Artefatos lista/row** | `ArtifactListJudgment` → list silence/list(N) · row · empty visualizable · close |
| **Assinatura editorial (turno)** | `EditorialTurnJudgment` → signature present/absent · feedback spoken · pack |
| EditorialTurn parts | `EditorialTurn` host · `EditorialTurnChrome` (FeedbackRow · SignatureLine) |
| **Markdown blocks spoken** | `AtlasMarkdownJudgment` list/quote/code/copy · Surface/Blocks |
| **Autônomos/Home residual spoken** | Digest/Evolution/Hub/Decision + HomeOps profile |
| **Mid-thread pack hydration** | `ConversationOccasionPack.PublishedSlice` + model.turnFacts rebind |
| **Arena run status chrome** | `ArenaRunStatusJudgment` · primitives host chrome fused |
| **Arena stop governance** | `ArenaStopJudgment` face blocked/ready · StopSheet |
| **Arena execution pipeline** | `ArenaPipelineJudgment` project/glyph/spoken · ExecutionPipeline |
| **LiveNow row spoken** | `LiveNowJudgment` spokenRow/clock · LiveNowRow |
| **Artifact sheet parts** | host/list · Chrome · Preview · Delivery |
| **Radar rows parts** | FolderRow · RepoChrome · AskContext |
| **Root chrome** | `RootChrome` · `RootChromeConversationRoutes` · Lifecycle · DeepLink · `RootView` home chrome · `ThreadRow` |
| **TurnPresence parts** | host · Activity · Runtime |
| **LiveTimeline parts** | host · NarrativeRow · NarrativeRowView |
| **Commit row parts** | Body · Meta |
| **Conversation composer sheets** | `ConversationComposerSheetsModifier` (API · host · camera; was 4 peels) |
| **Search surface parts** | `SearchSurface` host (header·results fused) |
| **Plan card parts** | PlanCard host (steps fused) · `PlanRevisionCompare` · StepRow · FlexWrap |
| **Workspace surface parts** | Surface · Body/threads |
| **Composer toolbar parts** | Chrome · ChromeBody |
| **Provenance sheet body** | `AtlasCodeProvenanceSheetBody` (was Sections*) · WhyTarget |
| **Surface graph parts** | Graph · GraphBody |
| **ArenaRunSheet parts** | host · Body |
| **ExecutionStateCard parts** | host · body · spoken · action style (fused; Judgment separate) |
| **AutonomosView parts** | View · Header |
| **ChangeReview patch parts** | PatchBody · DiffViewBody |
| **Markdown blocks parts** | Blocks · ViewBlocks |
| **A11yID domain parts** | core · Arena · Code · Autonomos |
| **ChangeReview Judgment** | `ChangeReviewJudgment` (risk · rank · spoken · pack · governance) |
| **SelfConstruction receipt chrome** | `SelfConstructionReceiptChrome` · Body · BodyChrome (sheet veto) |
| **Root home sections parts** | Body · Live |
| **LiveTimeline narrative (fused)** | `LiveTimelineNarrativeRow` (RowView fused) · Chrome |
| **AutonomosDecision Judgment** | `AutonomosDecisionJudgment` (faces · spoken · packFacts) |
| **ArenaModel parts** | host · Actions |
| **AutonomosModel parts** | host · Actions |
| **ChangeReview governance parts** | `ChangeReviewGovernance` (Body+Chrome fused) |
| **Code sheets modifiers parts** | Modifiers · Body |
| **AtlasSession parts** | host · Body |
| **Code surface parts** | Surface · Body |
| **ExecutionProof Judgment** | `ExecutionProofJudgment` (face · spoken · quality · pack) |
| **PlanJudgment** | `PlanJudgment` (face · spoken · packFacts) |
| **LiveNowJudgment** | single file: merge · rank · spoken · pack (was core+Row peels) |
| **ComposerDraftJudgment parts** | core · attach spoken fused |
| **ChangeReview body / sheet** | `ChangeReviewBody` (controls/tests/decided/run) · `ChangeReviewSheetBody` |
| **ArenaSuiteSheet parts** | Sheet · Body |
| **RootChrome parts** | Chrome · Lifecycle · DeepLink · `RootChromeConversationRoutes` (ThreadRow own file) |
| **ExecutionStateCard spoken** | fused in `ExecutionStateCard` (was Spoken·Body peels) |
| **Composer sheets modifier parts** | Modifier · Body |
| **ExecutionProof body** | `ExecutionProof` decision/quality/replay (was Sections*) |
| **Markdown view blocks parts** | ViewBlocks · Body |
| **SelfConstruction veto spoken** | `SelfConstructionVetoJudgment` · Receipt Chrome fields |
| Design tokens | `AtlasTheme` / `AtlasType` / `AtlasMotion` |
| **Artifact preview pack** | `ArtifactPreviewJudgment` → OccasionPack idle when list non-empty |
| **Artifact contract + evidence pack** | `ArtifactJudgment` · `TraceEvidenceJudgment` → OccasionPack |
| **Autônomos pack** | `AutonomosAskContext` host · organs global/veto/destination (fused) |
| **Markdown surface** | `AtlasMarkdownSurface` · Code · Lists · `CodeBlockView` |
| **EditorialTurn** | host · Closing · User · Chrome |
| **PlanCard** | Body · FlexWrap · Steps |
| **Autonomos pack organs** | fused in `AutonomosAskContext` (global · veto · destination) |
| **Residual composition** | PlanCard FlexWrap · StepRow · ModelActions* · FileRowChrome · Decision surface fused |

## BLOCKED (honesto)

- App Group / Fleet·CodeWeek widget **data** restore
- Core novos campos / endpoints (`Sources/**`, ConversationModel lógica)
- Device proof sem passcode do operador

## Densidade (lembrete)

View/Shell rota ≤600 · Surface 1 domínio ≤1500 (fail &gt;2000) · um domínio por arquivo.
