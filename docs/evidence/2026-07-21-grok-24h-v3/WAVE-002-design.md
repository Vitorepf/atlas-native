# WAVE-002 — occasion-pack-ops

**Status:** design approved  
**Wave:** `WAVE-002-occasion-pack-ops`  
**Owner:** casca · 2026-07-21  

## Problema

A lei da pílula: **inteligência = pack da ocasião**. Depois de WAVE-001 (grafo + radar pill), ainda:

1. **Workspace** abre conversa com pack **Home** (mistura de mundos).
2. **Pílula do Workspace** mostra invite Home.
3. **Radar** tem pack textual mas `workspace: nil` no sheet.
4. **Arena destination** força `tab: .now` (invite/suggestions usam destination; facts mapeiam — limpar para honestidade).
5. **Autônomos facts** finos na unit; destino só como `navTitle`.

## Patamar

Cada superfície ops compila **seu** pack presentation-only: invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts da **mesma** ocasião. Home continua partida; Workspace não é Home.

## Arquitetura

- `WorkspaceAskContext` novo (espelha `HomeAskContext`).
- Wire `RootView+DestinationsConversation+New` e pill Workspace.
- Radar: bind `workspace` a root/recents quando existir; ausência explícita no pack.
- Arena dest: `tab` derivado de destination (`tabForDestination` público ou inline).
- Autônomos: facts com dest + unit campos já expostos.
- Zero Core. Zero NL write.

## Arquivos

| Path | Mudança |
|---|---|
| `App/Atlas/WorkspaceAskContext.swift` | **new** pack |
| `App/Atlas/RootView+DestinationsConversation+New.swift` | workspace vs free/home |
| `App/Atlas/WorkspaceView+ChromeNewPillLabel.swift` | invite workspace |
| `App/Atlas/AtlasCodeRadarView+AskPill.swift` | workspace bind |
| `App/Atlas/AtlasCodeRadarAskContext.swift` | absences se sem workspace |
| `App/Atlas/ArenaPremiumDestinationView.swift` | tab derivado |
| `App/Atlas/ArenaPremiumAskContext.swift` | helper tab público se preciso |
| `App/Atlas/AutonomosAskContext.swift` | facts depth dest |

## DoD (≥5)

1. Workspace **X** → invite/suggestions/facts mencionam X + threads do workspace, não “Contexto Home”.
2. Home / livre (`workspaceKey == nil`) → pack Home/livre, sem fingir workspace.
3. Radar sheet: `workspace` = root ou slug real se model tem; senão nil + absence no pack.
4. Arena destination pack permanece destination-true (sem “Agora” falso no texto de tela).
5. Autônomos facts incluem tela destino + unit; create honesty mantida.
6. Regressão WAVE-001: Code emptyPrompt ainda usa focus legend.
7. Gates: checks + build + guard; hosts ≤400.

## Anti-objetivos

- Inventar pack Core tipado.
- NL mandar-fazer.
- Micro copy-only num host.
- Collapse god-files.

## Plano W3

Fuse peels Workspace pill / AskContext adjacentes se criados demais. Meta ΔLOC: **−100 a −300** se houver over-split; senão relatório honesto (product Δ > compress).

## Gates

`./scripts/grok-god-wave-guard.sh` · `swift run AtlasCoreChecks` · `cd App && make build`
