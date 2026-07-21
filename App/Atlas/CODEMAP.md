# Atlas Native — CODEMAP (casca)

> Mapa curto para IA. Manter verdadeiro. Grok B atualiza após W3 / idle que mude topologia.  
> Canon: `docs/prompts/grok-god-code-canon.md`

## Superfícies → entrada

| Superfície | Entry / shell | Núcleo vivo (não exaustivo) |
|---|---|---|
| Home | `RootView.swift` | `RootChrome*`, `RootHome*`, `Workspace*` |
| Conversa | `ConversationView.swift` | `ConversationSurface`, `ConversationChrome*`, Messages/Cockpit/Composer* |
| Código | `AtlasCodeView.swift` | `AtlasCodeSurface`, Radar*, Graph*, CommitRow*, Provenance* |
| Radar (multi-repo) | `AtlasCodeRadarView.swift` | `AtlasCodeRadarSurface`, `AtlasCodeRadarRows`, `AtlasCodeRadarJudgment`, `AtlasCodeRadarA11y` |
| Pílula | (dock por superfície) | `AgenticPill`, `AgenticOccasionPack`, `AgenticAskDock` |
| Arena Premium | `ArenaPremiumShell.swift` | Execution/Fleet/Results/Suite/Run/Score* |
| Autônomos | `AutonomosHubView.swift` / `AutonomosView.swift` | Hub/Map/List/`AutonomosDecision*`/Chrome* |
| Continuity | Widgets + ActivityKit | Island/Lock chrome — **App Group data BLOCKED** |

## Onde muda X

| Intenção | Comece em |
|---|---|
| Ordem/julgamento frota Radar | `AtlasCodeRadarJudgment` → Rows/View |
| **Radar screen load (frota)** | `AtlasCodeRadarScreenJudgment` → face loading/failed/empty/ready · shell a11y |
| Grafo single-repo judgment (fatia default) | `AtlasCodeGraphJudgment` → filter chips / list / pack |
| **Grafo worktrees** | `AtlasCodeWorktreeJudgment` → section silence/list(N) · rank dirty-first · pack |
| Código grafo peels | `AtlasCodeSurface` host · `AtlasCodeSurfaceGraph` content/list |
| **Grafo screen load (Código)** | `AtlasCodeGraphScreenJudgment` → face loading/failed/empty/ready · screen a11y |
| **Pílula ask (Código)** | `AtlasCodeAskPillJudgment` → face invite/anchoring/legend · AskContext pack |
| **Repo health (scan·heal·week·mirror)** | `AtlasCodeRepoHealthJudgment` → HealthStrip · Ask pack face |
| **Heal veto / undoError** | `AtlasCodeHealVetoJudgment` → ReceiptSheet · canVeto · undo fail line |
| **Commit row face (grafo)** | `AtlasCodeCommitRowJudgment` → dim/fora/main · tip branch · meta color |
| Commit row peels | `AtlasCodeCommitRowBody` · `AtlasCodeCommitRowA11y` (spoken identity/state) |
| **Why biografia arquivo (H1)** | `AtlasCodeWhyJudgment` → face loading/fail/empty/timeline/truncated |
| **Proveniência do commit** | `AtlasCodeProvenanceJudgment` → face loading/fail/empty/body · state kicker |
| Pack da pílula / ocasião | `AgenticOccasionPack` + hosts Ask |
| Pack mid-thread conversa | `ConversationOccasionPack` (nunca `HomeAskContext` em `.thread`) |
| Workspace/Search live-first list | `WorkspaceThreadJudgment` → rank + ThreadRow threadId running |
| **Search screen (shell)** | `SearchScreenJudgment` → face loading/offline/empty/results · screen a11y |
| **Search list/row** | `SearchListJudgment` → list recent/results/miss · captions · row · miss headline |
| **Workspace screen (lista)** | `WorkspaceScreenJudgment` → face loading/offline/empty/list · screen a11y |
| **Workspace picker (sheet)** | `WorkspacePickerJudgment` → face loading/failed/empty/list/miss · rank · pack |
| **Workspace empty editorial** | `WorkspaceEmptyJudgment` → face area/free/workspace · glyph empty |
| **Ops failure (multi-superfície)** | `AtlasOpsFailureJudgment` → face network/domain/load · FailureEmpty |
| Phase grammar execução (strip/presence) | `ConversationExecutionPhase` → strip/StateCard/LiveNow/composer `selectPresenceBubble` |
| **LiveNow attention (Home hub)** | `LiveNowJudgment` → rank · headForOpen (Seguir) · pack anchors · section face |
| **StateCard kind chrome** | `ExecutionStateCardJudgment` → icon/badge/spoken/tint/timer freeze |
| **Narrativa viva (timeline face)** | `LiveTimelineNarrativeJudgment` → face live/filterSilence (chrono sagrado) |
| **Filtro de leitura (timeline)** | `LiveTimelineFilterJudgment` → face open/active/silent · chip/silence spoken |
| Timeline filter peels | `LiveTimelineFilterChrome` (ReadFilter + FilterChips) |
| **Continuidade handoff (iPhone↔Mac)** | `ConversationHandoffJudgment` → receipt face ready/pending/other |
| **Composer send readiness** | `ComposerSendJudgment` → face ready/blocked/queue · gold gate · draft rank |
| **Composer draft/anexos** | `ComposerDraftJudgment` → strip silence/drafts(N)/uploading/failed · thumb · DraftStrip |
| **Composer toolbar chrome** | `ComposerToolbarJudgment` → attach/options/mode/workspace spoken · pack |
| **Composer esforço** | `ComposerEffortJudgment` → face auto/fast/balanced/deep/max · toolbar/sheet spoken |
| **Composer folhas modo/workspace** | `ComposerSheetJudgment` → mode face · workspace sheet empty/list |
| Composer sheet peels | `ComposerSheetPrimitives` (EffortSheet · SheetRow · NewMarker) · SheetsHost |
| **Composer fila (head FIFO)** | `ComposerQueueJudgment` → chip head snippet · sheet spoken · pack |
| **Stale-read cache seal** | `ConversationStaleReadJudgment` → face confirming/fresh/aged/stale |
| **Messages surface (lista)** | `ConversationMessagesJudgment` → face load_fail/empty/messages · list a11y |
| Messages peels | `ConversationMessages` host · `ConversationMessagesScroll` · `ConversationMessagesEditorial` |
| **Empty editorial (partida)** | `ConversationEmptyJudgment` → face silence/default_prompt/custom_prompt/suggestions(N) · EmptyStates |
| **Índice da conversa (outline)** | `ConversationOutlineJudgment` → face empty/turns · `ConversationOutlineSheet` |
| **Home OPERAÇÃO attention** | `HomeOpsJudgment` → Autônomos door face · Arena door · pack |
| **Autônomos can_do honesty** | `AutonomosCanDoJudgment` → matrix dest×control×canControl · AskContext pack |
| **Autônomos lista/row** | `AutonomosListJudgment` → list empty/list(N) · row awaiting/live/quiet · pack |
| **Autônomos hub** | `AutonomosHubJudgment` → hubFace · spokenHub · receiptTone · pack |
| **Autônomos razão governada** | `AutonomosReasonJudgment` → face blocked/ready · ReasonSheet |
| Presence primary chrome (face lead) | `ConversationExecutionPhase.primarySpoken` + `selectPresenceBubble` · dual-surface 012 |
| Conversation mid-run **Escolher** | `ConversationDecisionJudgment` → ExecutingStrip → `resolveExecutionChoice` |
| **Live strip CTAs** | `ConversationLiveStripJudgment` → stop/steer/choose spoken · compound strip · pack |
| **Conversation can_do pack** | `ConversationCanDoJudgment` → matrix live×decision · OccasionPack wire |
| Cockpit peels | `ConversationCockpitBody` (strip·lanes) · `ConversationCockpitBanners` (banner·reconnect·silence) |
| **Steer / redirecionar** | `ConversationSteerJudgment` → receipt face · scope PT · allowsSubmit |
| **Agent lanes (multi)** | `ConversationAgentLanesJudgment` → ExecutionRibbon rank failed-first |
| Island/Lock phase chrome | Widgets Live/Lock* (sem inventar App Group) |
| Score/julgamento Arena | `ArenaScoreJudgment` + Suite/Run sheets |
| **Arena capacidades (confiança)** | `ArenaCapabilitiesJudgment` → measured/improved/regressed one law · rank · pack |
| **Arena agora (fase)** | `ArenaNowJudgment` → face idle/queued/running/terminal · NowStates chrome |
| **Arena pack can_do honesty** | AskContext wires Now+LiveControl packFacts · canDo matrix · canStop one law |
| **Arena plano/fila** | `ArenaPlanQueueJudgment` → planFace empty/published/derived_live · queueFace |
| **Arena live control (corridas)** | `ArenaLiveControlJudgment` → rank · face · canStop |
| **Arena start / recibo rodar** | `ArenaStartJudgment` → submit face · receipt face · worker gap |
| **Arena run sheet (shell)** | `ArenaRunSheetJudgment` → face empty_engines/empty_suites/ready |
| **Arena suite drill** | `ArenaSuiteJudgment` → rank regressed-first · suite face |
| **Decisão Autônomos (julgar + assinar)** | `AutonomosDecisionJudgment` → `AutonomosDecisionSurface` → Hub CTA / MapShell `.decisions` / `AutonomosModel.decide` |
| **Controle do loop Autônomos (veto)** | `AutonomosRunControlJudgment` → Hub primaryVerb → ReasonSheet → `model.control` / `startRun` · bind `selectArea` |
| **Multi-área bind (chooser)** | `AutonomosAreaBindJudgment` → face none/auto/needs_bind/bound · `AutonomosAreaBindChooser` · Hub CTA |
| **Proposta noturna** | `NightlyProposalJudgment` → face pending/muted/muted_auto/hidden · Block/Card/Rhythm |
| **Ritmo do dia (aprender)** | `AutonomosRhythmJudgment` → face learning/learned/paused · line/sheet |
| **Veto retroativo self-construction** | `SelfConstructionVetoJudgment` → ReceiptSheet canRevert → `model.revertCycle` |
| **Evolução / entregas Autônomos** | `AutonomosEvolutionJudgment` → EvolutionView marcos → receipt |
| **Transfer handoff missão** | `AutonomosTransferJudgment` → Hub CTA → ReasonSheet → `model.transfer` |
| **Task health / incidente frota** | `AutonomosTaskHealthJudgment` → IncidentSurface · vestment incidentPresent |
| **Frota global (agentes vivos)** | `AutonomosFleetJudgment` → FleetStrip no catálogo |
| **Digest / momento (janela)** | `AutonomosDigestJudgment` → DigestSurface · `.moment("digest")` |
| **Change review risk (achados/patches)** | `ChangeReviewJudgment` → RiskStrip + FindingsBody/PatchBody · sheet spoken |
| **Change review sheet load** | `ChangeReviewSheetJudgment` → face loading/unavailable/empty/ready |
| Change review peels | Sections host · `ChangeReviewSectionsA11y` spoken · Governance/Patch bodies |
| Change review peels | Sections host · GovernanceBody · RunActionsBody · PatchBody · FindingsBody |
| **Plan progresso (card + cockpit)** | `PlanJudgment` → PlanFaceStrip · stepState · strip summary |
| Plan card peels | `PlanCard` host · `PlanCardRevisionBody` · `PlanCardStepRow` |
| **Artefatos / evidência do turno** | `ArtifactJudgment` → FaceStrip · kind rank · delivery fail-first |
| **Preview de artefato** | `ArtifactPreviewJudgment` → face idle/load/loaded/tooLarge/failed |
| Artifact sheet peels | `ArtifactSheet` host · `ArtifactSheetDelivery` (mount) |
| Preview peels | `ArtifactPreviewChrome` host · `TraceEvidenceChrome` · `ArtifactPreviewZoom` |
| **Trace evidence chrome** | `TraceEvidenceJudgment` → loading/unavailable · reason honesty · Loading/Unavailable views |
| **Prova de execução (card recolhido)** | `ExecutionProofJudgment` → face kicker · qualityLine/spoken · activity · replay absence |
| **Artefatos lista/row** | `ArtifactListJudgment` → list silence/list(N) · row · empty visualizable · close |
| **Assinatura editorial (turno)** | `EditorialTurnJudgment` → signature present/absent · feedback spoken · pack |
| EditorialTurn peels | `EditorialTurn` host · `EditorialTurnChrome` (FeedbackRow · SignatureLine) |
| Design tokens | `AtlasTheme` / `AtlasType` / `AtlasMotion` |

## BLOCKED (honesto)

- App Group / Fleet·CodeWeek widget **data** restore  
- Core novos campos / endpoints (`Sources/**`, ConversationModel lógica)  
- Device proof sem passcode do operador  

## Densidade (lembrete)

View/Shell rota ≤600 · Surface 1 domínio ≤1500 (fail &gt;2000) · um domínio por arquivo.
