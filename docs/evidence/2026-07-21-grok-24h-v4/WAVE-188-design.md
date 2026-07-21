# WAVE-188 — conversation-thread-live-and-autonomos-destination-pack

**Status:** design · proposed · high
**Wave:** WAVE-188-conversation-thread-live-and-autonomos-destination-pack
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 187
**Δ patamar:** **high**

## Problema
1. **ConversationOccasionPackLive.appendLiveSessionFacts** still hand-rolls
   `sessoes_vivas_deste_fio` · `live_detail` · hub_global while strip/can_do/
   decision packs exist — last mid-thread live-session soup.
2. **AutonomosAskContextOrgansDestination** hand-rolls `tela`/`foco` routing
   strings for every destination while hub/decision/evolution organs are
   packed — dual dialect for destination identity.

## Patamar
| Antes | Depois |
|---|---|
| thread live hand-roll | ConversationThreadLiveJudgment.packFacts |
| destino foco hand-roll | AutonomosDestinationJudgment.packFacts |
| dual discovery | one law packFacts |

Δ = thread-live + Autônomos destination pack sovereignty.

## Arquitetura
Casca only · TurnPresence + session remotes published · destination enum pure.

### Fluxo
```
ConversationThreadLiveJudgment.packFacts(matchingLive, hubCount)
  → appendLiveSessionFacts wires pack only

AutonomosDestinationJudgment.packFacts(destination)
  → appendDestinationOrgans wires shell then organ packs
```

### Arquivos (≥5)
1. ConversationThreadLiveJudgment.swift (**new**)
2. ConversationOccasionPackLive.swift — wire
3. AutonomosDestinationJudgment.swift (**new**) or Destination.swift peel
4. AutonomosAskContextOrgansDestination.swift — wire
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
new Judgments 80–120 · hosts ↓LOC

### Fora de escopo
Core · invent live · density peels · tipografia · ConversationModel logic

### §5
nenhum

## DoD produto (≥5)
- [ ] thread live packFacts external caller
- [ ] sessoes_vivas_deste_fio · live_detail · hub honesty
- [ ] destination packFacts tela/foco product words
- [ ] hosts lose hand-roll for those fields
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
invent sessions · invent dest · micro · Core

## Plano W3
1. Thread live Judgment 2. Wire Live 3. Destination Judgment 4. Wire organs 5. gates CODEMAP DONE

## Proof
1. no matching live → count 0
2. matching live with phaseTitle → live_detail
3. hub > matching → hub_global fact
4. destination .decisions → foco decisões
5. DEVICE_PENDING

## Council
Last host hand-rolls on conversation live sessions + Autônomos dest routing.

### Why full-bar
≥5 files · ≥120 design · DoD≥5

### Rejection
one surface alone · MARK-only

### Related
WAVE-185 thread shell · WAVE-186 hub-live · WAVE-179 decision pack

### Sequence after
await A

### Acceptance
Build green

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — thread live pack

```
facts:
- thread_live_count: N
- thread_live_detail · title · phaseTitle
- thread_live_hub_global: M (when hub > matching)
anchors:
- live · title · product
absences:
- (none when empty — count 0 is fact)
```

## Appendix — destination pack

```
facts:
- autonomos_tela: navTitle | catalogo
- autonomos_foco: hub|decisions|evolution|moment|incident
```

## Appendix — non-goals
Change destination routing · invent hub live as scoped

## Appendix — risk
phaseTitle empty → skip detail line

## Appendix — test matrix

| case | expect |
|---|---|
| matching 0 | count 0 |
| hub 5 matching 1 | hub_global |
| dest nil | catalogo |

## Appendix — commit
`feat(ui): WAVE-188 thread-live and autonomos destination pack`

## Appendix — god
one law thread live · one law dest shell

## Appendix — dual A
—

## Appendix — density
hosts thinner

## Appendix — a11y
unchanged

## Appendix — idle
product pack not MARK
