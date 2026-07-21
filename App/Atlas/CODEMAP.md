# Atlas Native — CODEMAP (casca)

> Mapa curto para IA. Manter verdadeiro. Canon: `docs/prompts/grok-god-code-canon.md`
> GOD RESTRUCTURE v4: densos agent-optimal hosts; Type.method navigation.

## Superfícies → entrada

| Superfície | Entry / host | Núcleo vivo |
|---|---|---|
| Home | `RootView` | `RootChrome` · `RootHomeBody` · `HomeOpsJudgment` |
| Conversa | `RootView` / `ConversationSurface` | Messages · Composer · Judgments · Model |
| Código | `AtlasCodeSurface` | Radar · Provenance · Graph · CommitRow |
| Pílula | dock in hosts | `AgenticPill` (in RootView) |
| Arena | `ArenaPremiumShell` | Execution · Surfaces · FleetJudgment |
| Autônomos | `AutonomosHost` | Map · Model · CanDoJudgment |
| Continuity | Widgets + `TurnPresence` | ActivityKit chrome — App Group data BLOCKED |

## Onde muda X (hot paths)

| Intenção | Comece em |
|---|---|
| Home ops / partida | `HomeOpsJudgment` · `RootHomeBody` |
| LiveNow attention | `RootHomeBody` (LiveNow*) |
| Conversation mid-thread | `ConversationSurface` · `ConversationMessagesJudgment` |
| Composer send/toolbar | `ConversationComposer` · `ComposerToolbar` |
| Execution card / proof | `ExecutionStateCard` |
| Plan card | `PlanCard` |
| Change review | `ChangeReviewView` · `ChangeReviewJudgment` |
| Radar multi-repo | `AtlasCodeRadarSurface` |
| Provenance / Why | `AtlasCodeProvenanceSheet` |
| Code graph | `AtlasCodeSurface` · `AtlasCodeGraphJudgment` |
| Arena now/run/fleet | `ArenaPremiumShell` · `ArenaPremiumSurfaces` · `ArenaFleetJudgment` |
| Autônomos decide/map | `AutonomosHost` · `AutonomosMap` · `AutonomosCanDoJudgment` |
| Workspace catalog | `WorkspaceSurface` |
| Search | `SearchSurface` |
| Design system | `RootChrome` (Theme/A11y fused) · tokens |

## BLOCKED

- App Group / Continuity data wire — Core
- `Sources/**` · new ConversationModel/AtlasSession logic
- WAVE produto / dual A/B

## Densidade (v4)

View/Shell de rota ≤600 · qualquer casca ≤2000 · 1 domínio por host
