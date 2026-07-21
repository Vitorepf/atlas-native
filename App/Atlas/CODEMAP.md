# Atlas Native — CODEMAP (casca)

> Mapa curto para IA. Manter verdadeiro. Grok B atualiza após W3 / idle que mude topologia.  
> Canon: `docs/prompts/grok-god-code-canon.md`

## Superfícies → entrada

| Superfície | Entry / shell | Núcleo vivo (não exaustivo) |
|---|---|---|
| Home | `RootView.swift` | `RootChrome*`, `RootHome*`, `Workspace*` |
| Conversa | `ConversationView.swift` | `ConversationSurface`, `ConversationChrome*`, Messages/Cockpit/Composer* |
| Código | `AtlasCodeView.swift` | `AtlasCodeSurface`, Radar*, Graph*, CommitRow*, Provenance* |
| Radar (multi-repo) | `AtlasCodeRadarView.swift` | `AtlasCodeRadarSurface`, `AtlasCodeRadarRows`, `AtlasCodeRadarJudgment` |
| Pílula | (dock por superfície) | `AgenticPill`, `AgenticOccasionPack`, `AgenticAskDock` |
| Arena Premium | `ArenaPremiumShell.swift` | Execution/Fleet/Results/Suite/Run/Score* |
| Autônomos | `AutonomosHubView.swift` / `AutonomosView.swift` | Hub/Map/List/`AutonomosDecision*`/Chrome* |
| Continuity | Widgets + ActivityKit | Island/Lock chrome — **App Group data BLOCKED** |

## Onde muda X

| Intenção | Comece em |
|---|---|
| Ordem/julgamento frota Radar | `AtlasCodeRadarJudgment` → Rows/View |
| Grafo single-repo judgment (fatia default) | `AtlasCodeGraphJudgment` → filter chips / list / pack |
| **Repo health (scan·heal·week·mirror)** | `AtlasCodeRepoHealthJudgment` → HealthStrip · Ask pack face |
| **Heal veto / undoError** | `AtlasCodeHealVetoJudgment` → ReceiptSheet · canVeto · undo fail line |
| **Commit row face (grafo)** | `AtlasCodeCommitRowJudgment` → dim/fora/main · tip branch · meta color |
| **Why biografia arquivo (H1)** | `AtlasCodeWhyJudgment` → face loading/fail/empty/timeline/truncated |
| **Proveniência do commit** | `AtlasCodeProvenanceJudgment` → face loading/fail/empty/body · state kicker |
| Pack da pílula / ocasião | `AgenticOccasionPack` + hosts Ask |
| Pack mid-thread conversa | `ConversationOccasionPack` (nunca `HomeAskContext` em `.thread`) |
| Workspace/Search live-first list | `WorkspaceThreadJudgment` → rank + ThreadRow threadId running |
| Phase grammar execução (strip/presence) | `ConversationExecutionPhase` → strip/StateCard/LiveNow/composer `selectPresenceBubble` |
| **StateCard kind chrome** | `ExecutionStateCardJudgment` → icon/badge/spoken/tint/timer freeze |
| **Narrativa viva (timeline face)** | `LiveTimelineNarrativeJudgment` → face live/filterSilence (chrono sagrado) |
| **Continuidade handoff (iPhone↔Mac)** | `ConversationHandoffJudgment` → receipt face ready/pending/other |
| **Composer send readiness** | `ComposerSendJudgment` → face ready/blocked/queue · gold gate · draft rank |
| **Composer fila (head FIFO)** | `ComposerQueueJudgment` → chip head snippet · sheet spoken · pack |
| **Home OPERAÇÃO attention** | `HomeOpsJudgment` → Autônomos door face · Arena door · pack |
| Presence primary chrome (face lead) | `ConversationExecutionPhase.primarySpoken` + `selectPresenceBubble` · dual-surface 012 |
| Conversation mid-run **Escolher** | `ConversationDecisionJudgment` → ExecutingStrip → `resolveExecutionChoice` |
| **Steer / redirecionar** | `ConversationSteerJudgment` → receipt face · scope PT · allowsSubmit |
| **Agent lanes (multi)** | `ConversationAgentLanesJudgment` → ExecutionRibbon rank failed-first |
| Island/Lock phase chrome | Widgets Live/Lock* (sem inventar App Group) |
| Score/julgamento Arena | `ArenaScoreJudgment` + Suite/Run sheets |
| **Arena live control (corridas)** | `ArenaLiveControlJudgment` → rank · face · canStop |
| **Arena start / recibo rodar** | `ArenaStartJudgment` → submit face · receipt face · worker gap |
| **Decisão Autônomos (julgar + assinar)** | `AutonomosDecisionJudgment` → `AutonomosDecisionSurface` → Hub CTA / MapShell `.decisions` / `AutonomosModel.decide` |
| **Controle do loop Autônomos (veto)** | `AutonomosRunControlJudgment` → Hub primaryVerb → ReasonSheet → `model.control` / `startRun` · bind `selectArea` |
| **Veto retroativo self-construction** | `SelfConstructionVetoJudgment` → ReceiptSheet canRevert → `model.revertCycle` |
| **Evolução / entregas Autônomos** | `AutonomosEvolutionJudgment` → EvolutionView marcos → receipt |
| **Transfer handoff missão** | `AutonomosTransferJudgment` → Hub CTA → ReasonSheet → `model.transfer` |
| **Task health / incidente frota** | `AutonomosTaskHealthJudgment` → IncidentSurface · vestment incidentPresent |
| **Frota global (agentes vivos)** | `AutonomosFleetJudgment` → FleetStrip no catálogo |
| **Digest / momento (janela)** | `AutonomosDigestJudgment` → DigestSurface · `.moment("digest")` |
| **Change review risk (achados/patches)** | `ChangeReviewJudgment` → RiskStrip + FindingsBody/PatchBody · sheet spoken |
| **Plan progresso (card + cockpit)** | `PlanJudgment` → PlanFaceStrip · stepState · strip summary |
| **Artefatos / evidência do turno** | `ArtifactJudgment` → FaceStrip · kind rank · delivery fail-first |
| **Prova de execução (card recolhido)** | `ExecutionProofJudgment` → face kicker · shouldDisplay · ranked artifacts |
| Design tokens | `AtlasTheme` / `AtlasType` / `AtlasMotion` |

## BLOCKED (honesto)

- App Group / Fleet·CodeWeek widget **data** restore  
- Core novos campos / endpoints (`Sources/**`, ConversationModel lógica)  
- Device proof sem passcode do operador  

## Densidade (lembrete)

View/Shell rota ≤600 · Surface 1 domínio ≤1500 (fail &gt;2000) · um domínio por arquivo.
