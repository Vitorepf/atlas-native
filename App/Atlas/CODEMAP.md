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
| Pack da pílula / ocasião | `AgenticOccasionPack` + hosts Ask |
| Phase grammar execução (strip/presence) | `ConversationExecutionPhase` → strip/StateCard/LiveNow/composer `selectPresenceBubble` |
| Presence primary chrome (face lead) | `ConversationExecutionPhase.primarySpoken` + `selectPresenceBubble` · dual-surface 012 |
| Island/Lock phase chrome | Widgets Live/Lock* (sem inventar App Group) |
| Score/julgamento Arena | `ArenaScoreJudgment` + Suite/Run sheets |
| **Decisão Autônomos (julgar + assinar)** | `AutonomosDecisionJudgment` → `AutonomosDecisionSurface` → Hub CTA / MapShell `.decisions` / `AutonomosModel.decide` |
| Design tokens | `AtlasTheme` / `AtlasType` / `AtlasMotion` |

## BLOCKED (honesto)

- App Group / Fleet·CodeWeek widget **data** restore  
- Core novos campos / endpoints (`Sources/**`, ConversationModel lógica)  
- Device proof sem passcode do operador  

## Densidade (lembrete)

View/Shell rota ≤600 · Surface 1 domínio ≤1500 (fail &gt;2000) · um domínio por arquivo.
