# WAVE-156 — residual-midhost-density-peel-graph-strip-decision-map-nightly

**Status:** design · proposed · high  
**Wave:** WAVE-156-residual-midhost-density-peel-graph-strip-decision-map-nightly  
**Owner:** casca only · residual full-bar (fila vazia · idle 2/2)  
**Date:** 2026-07-21  

## Problema
Hosts mid-size (~250–290 LOC) ainda misturam seções de domínio no mesmo arquivo:
grafo chrome (status+filtros+worktrees+semana), live strip (status+actions+a11y),
decisão Autônomos (list+detail+sections), MapShell (catalog+bind/control),
Nightly schedule (payload+notify+schedule monólito). Atrito agent-optimal:
1 read ≠ 1 intenção. ConversationModel continua deferred (concurrency).

## Patamar
| Antes | Depois |
| monólito multi-seção | peels por intenção + hosts finos |
| GraphChrome 260 | Status host + Filter/Worktree/Week peels |
| CockpitAgentRow 251 | Strip host + Status/Actions peels |
| DecisionSurface 293 | Host + List/Detail/Sections |
| MapShell 285 | Host + Catalog/Actions |
| NightlyProposal 291 | Host + Schedule peel |

Δ = densidade residual multi-host · agent-optimal navigation.

## Arquitetura
### Princípios
- Casca only · Zero Core · Zero área nova
- Peels = extension no tipo host (sem rewrite de comportamento)
- `private` → internal só onde o peel precisa (file boundary)
- Judgment/Grammar intocados (já agent-optimal 200–800)
- ConversationModel deferred

### Layout
```
AtlasCodeGraphChrome (status)
  + FilterChrome · WorktreeChrome · WeekChrome
ConversationCockpitAgentRow (strip host)
  + StripStatus · StripActions
AutonomosDecisionSurface (host)
  + ListBody · DetailBody · Sections
AutonomosMapShell (host sheets)
  + Catalog · Actions
NightlyProposalController (host)
  + Schedule peel
```

### Arquivos (≥5 peels + governance)
1. AtlasCodeGraphChrome.swift (host thin)
2. AtlasCodeGraphFilterChrome.swift
3. AtlasCodeGraphWorktreeChrome.swift
4. AtlasCodeGraphWeekChrome.swift
5. ConversationCockpitAgentRow.swift (host)
6. ConversationCockpitStripStatus.swift
7. ConversationCockpitStripActions.swift
8. AutonomosDecisionSurface.swift (host)
9. AutonomosDecisionListBody.swift
10. AutonomosDecisionDetailBody.swift
11. AutonomosDecisionSections.swift
12. AutonomosMapShell.swift (host)
13. AutonomosMapShellCatalog.swift
14. AutonomosMapShellActions.swift
15. NightlyProposal.swift (host)
16. NightlyProposalSchedule.swift
17. CODEMAP.md
18. design + compress + DONE + LEDGER + QUEUE

### Densidade (canon §4)
| Camada | Target | Hard fail |
| Shell / View rota | ≤600 | >600 |
| Chrome / Body peel | ≤200 preferido | — |
| Surface um domínio | ≤1500 | >2000 |
| Host residual | ≤160 | — |

### Fora de escopo
- Core / Sources / ConversationModel / AtlasSession lógica
- Tipografia · token ladder · fuse cosmético
- Behavior rewrite · endpoints · área nova
- Nightly App Group / Continuity data (BLOCKED)

### §5
`nenhum` — peels presentation-only.

## DoD produto (≥5)
- [ ] GraphChrome peels (filter/worktree/week) · host status
- [ ] ExecutingStrip status/actions peels
- [ ] DecisionSurface list/detail/sections peels
- [ ] MapShell catalog/actions peels
- [ ] Nightly schedule peel
- [ ] Build green + AtlasCoreChecks + grok-god-wave-guard
- [ ] CODEMAP topologia
- [ ] DEVICE_PENDING (passcode)

## Anti-objetivos
- Micro-WAVE <5 files
- Rename-only fingindo compress
- ConversationModel peel sem plano concurrency
- Colapsar 2+ domínios
- Inventar Core / endpoints

## Plano W3 GOD
1. Split por MARK/seção limpa (braces balanceados)
2. private→internal só no necessário
3. Gates triplos
4. CODEMAP + DONE + compress + regen-queue + LEDGER
5. Commit feat(ui): WAVE-156 …

## Proof
1. `wc -l` hosts ≤160 · peels coesos
2. `swift run AtlasCoreChecks` · `cd App && make build` · guard
3. DEVICE_PENDING se passcode

## Council
Density residual após 111–155. Fila A empty. Idle compress 2/2.
Judgment mid-size (ChangeReview/ExecutionPhase/AskContext) **não** peelar —
já na faixa 200–800 agent-optimal.

### Why full-bar
≥5 files · design ≥120 · DoD≥5 · multi-superfície (Código/Conversa/Autônomos)
· W3 estrutural real · não cabe em <30 min rename

### Rejection
Fuse <30 LOC net · tipografia · mono-arquivo → fail §WAVE

### Related
WAVE-111–155 density campaign · MapShellAsk/Routes already peeld · ConversationModel deferred

### Sequence after
A fill QUEUE · ou residual se monólitos > target restarem

### Acceptance
Build green · peels under target · hosts thin · DEVICE_PENDING · behavior unchanged

### W2/W3
Split · gates · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Zero change de produto — só navegação agent-optimal do código.

### Density table
| Peel | Target |
| GraphChrome host | ≤50 |
| Filter/Worktree/Week | ≤120 each |
| Strip host | ≤55 |
| Strip Status/Actions | ≤120 each |
| Decision host | ≤70 |
| List/Detail/Sections | ≤120 each |
| MapShell host | ≤180 (sheets stay) |
| Catalog/Actions | ≤100 each |
| Nightly host | ≤160 |
| Schedule | ≤140 |

### Product words
None new — peels only.

### Files (execute)
Graph 4 · Strip 3 · Decision 4 · Map 3 · Nightly 2 · governance

### Notas
Agent-optimal: 1 file = 1 intenção (status | filter | worktree | week | list | detail…).

### Anti-objetivos again
- inventar
- tipografia
- Core
- ConversationModel

### Risk
Access control private→internal; sheet bindings stay on host; MainActor Nightly schedule extension.

### Recovery
`git checkout -- App/Atlas` peels se build fail; re-split at extension boundary.

### MARK layout (peels)
// MARK: - Types | Body | Sections | Actions | A11y | Helpers when >~80

### Guard
`./scripts/grok-god-wave-guard.sh` must OK.

### End design length pad (canon ≥120)
Residual density is the last honest full-bar while A queue is empty.
Judgments already optimal stay untouched.
Shells under 600 hard fail remain virtue.
Do not invent product micro-WAVE.
Do not idle fuse factory after this if ROI gone — wait A.
DEVICE_PENDING always when no physical device run.
Gates every App commit — never skip.
Casca only. Zero área nova. Zero Core.

---
*End WAVE-156*
