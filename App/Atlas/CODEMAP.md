# Atlas Native — CODEMAP (casca)

> Mapa curto para IA. GOD RESTRUCTURE v4 densified hosts. Navigation = `Type.method`.

## Superfícies → host

| Superfície | Host principal |
|---|---|
| Home | `RootView` · `RootChrome` · `HomeOpsJudgment` |
| Conversa | `ConversationSurface` · Messages · Composer · Judgments · `ConversationModel` |
| Código | `AtlasCodeSurface` · Radar · Provenance · Graph |
| Arena | `ArenaPremiumRoot` · Execution · Surfaces · FleetJudgment |
| Autônomos | `AutonomosHost` · Map · Model · CanDoJudgment |
| Workspace/Search | `WorkspaceSurface` · `SearchSurface` |
| Continuity | `TurnPresence` · Widgets Host A/B |
| Design system | inside `RootChrome` (Theme/A11y) |

## Onde muda X

| Intenção | Host |
|---|---|
| LiveNow / Home ops | `HomeOpsJudgment` |
| Mid-thread conversation | `ConversationSurface` / `ConversationMessagesJudgment` |
| Composer | `ConversationComposer` / `ComposerToolbar` |
| Execution proof card | `ExecutionStateCard` |
| Plan | `PlanCard` |
| Change review | `ChangeReviewSurface` / `ChangeReviewJudgment` |
| Radar | `AtlasCodeRadarSurface` |
| Provenance/Why | `AtlasCodeProvenanceSheet` |
| Grafo | `AtlasCodeSurface` / `AtlasCodeGraph` |
| Arena | `ArenaPremiumRoot` / `ArenaPremiumSurfaces` / `ArenaFleetJudgment` |
| Autônomos | `AutonomosHost` / `AutonomosMap` / `AutonomosCanDoJudgment` |

## BLOCKED

Sources/** · ConversationModel/AtlasSession **logic** · App Group data · WAVE produto

## Densidade

route View/Shell ≤600 · any ≤2000 · soft Sections/States = 0
