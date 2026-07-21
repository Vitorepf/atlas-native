# WAVE-184 — autonomos-unit-focus-pack-and-home-catalog-pack

**Status:** design · proposed · high
**Wave:** WAVE-184-autonomos-unit-focus-pack-and-home-catalog-pack
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 183
**Δ patamar:** **high**

## Problema
1. **Autônomos host** still hand-rolls unit focus facts (carta ·
   catalogo_local pause honesty · idade_local) outside Judgment while
   hub/list/decision packs already exist — dual dialect for focused unit.
2. **Home Ask** hand-rolls `conversas_conhecidas` + workspace names while
   HomeOps / empty / picker / LiveNow are packed — catalog shell of Home
   partida still host soup.

## Patamar
| Antes | Depois |
|---|---|
| unit focus hand-roll | AutonomosListJudgment.packUnitFocusFacts |
| Home catalog hand-roll | HomeOpsJudgment or Home catalog packFacts |
| dual discovery | one law packFacts for unit + home catalog |

Δ = unit focus + Home catalog pack sovereignty.

## Arquitetura
Casca only · AutonomosUnit presentation fields already pure · session threads/workspaces published.

### Fluxo
```
AutonomosAskContext.facts
  → packUnitFocusFacts(unit) replaces carta/catalog/idade hand-roll

HomeAskContext.facts
  → HomeOpsJudgment.packCatalogFacts(threads, workspaces)
     or HomeCatalog pack
```

### Arquivos (≥5)
1. AutonomosListJudgment.swift — packUnitFocusFacts
2. AutonomosAskContext.swift — wire
3. HomeOpsJudgment.swift — packCatalogFacts (or HomeAskContext peel)
4. HomeAskContext.swift — wire
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
Judgment +40 · hosts ↓LOC

### Fora de escopo
Core · invent unit charter · density peels · tipografia · ConversationModel

### §5
nenhum

## DoD produto (≥5)
- [ ] packUnitFocusFacts external caller
- [ ] local pause ≠ server loop absence honesty
- [ ] Home catalog threads/workspaces packFacts
- [ ] hosts lose hand-roll for those fields
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
invent charter · claim server pause from local · micro rename alone

## Plano W3
1. unit pack 2. Autonomos wire 3. Home catalog pack 4. Home wire 5. gates CODEMAP DONE

## Proof
1. unit nil → list pack path unchanged
2. unit paused → catalogo_local honesty not server loop
3. Home empty threads → conversas_conhecidas: 0
4. DEVICE_PENDING

## Council
Last major host hand-rolls on Autônomos focus + Home partida catalog.

### Why full-bar
≥5 files · ≥120 design · DoD≥5

### Rejection
unit pack without Home · Home pack without unit

### Related
WAVE-030 unit pause · WAVE-090 list · WAVE-047 HomeOps

### Sequence after
await A

### Acceptance
Build green

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — unit pack shape

```
facts:
- unit_name: X
- unit_charter: …
- unit_catalog_local: paused_on_iphone | on_iphone
- unit_age_local: …
absences:
- (when nil unit handled by list pack)
```

## Appendix — home catalog

```
facts:
- home_threads_known: N
- home_workspaces: a, b, c
absences:
- nenhum workspace listado
```

## Appendix — non-goals
Hub vestment rework · server create Autônomo (§5)

## Appendix — risk
ageLabel/charter are presentation-safe on AutonomosUnit

## Appendix — test matrix

| case | expect |
|---|---|
| unit paused | local pause fact |
| unit live | on_iphone |
| home 0 ws | absence |

## Appendix — commit
`feat(ui): WAVE-184 autonomos unit focus and home catalog pack`

## Appendix — god
one law unit focus · one law home catalog

## Appendix — dual A
—

## Appendix — density
hosts thinner

## Appendix — a11y
unchanged

## Appendix — idle
product pack not MARK
