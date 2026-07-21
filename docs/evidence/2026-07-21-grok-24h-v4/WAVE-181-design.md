# WAVE-181 — arena-score-judgment-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-181-arena-score-judgment-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual pack campaign
**Δ patamar:** **high**

## Problema
`ArenaScoreJudgment` owns exclusive scoreboard state
(unmeasured/partial/published/regressed/quietHealthy) + Δ never-zero law
across Results · Fleet · Comparison — **zero packFacts**. Arena Ask pack
wires fleet/suite/capabilities but **not** the primary engine score
judgment state. Agent can invent “0” or miss partial/regressed honesty.

## Patamar
| Antes | Depois |
|---|---|
| Suite/fleet pack only | + score_state productWord |
| Δ UI-only | pack delta when pair published |
| unmeasured silent | absence never zero |

Δ = Arena scoreboard pack sovereignty.

## Arquitetura
Casca only · model.arenaPrimaryEngine + claimAllowed already published.

### Fluxo
```
ArenaPremiumAskContextScore.appendScoreOrgans
  → ArenaScoreJudgment.packFacts(engine:, claimAllowed:, alerts?)
  → always on score organs (primary engine)
```

### Arquivos (≥5)
1. ArenaScoreJudgment.swift — packFacts
2. ArenaPremiumAskContextScore.swift — wire
3. CODEMAP
4. design · compress · DONE · LEDGER
5. (optional) ArenaPremiumAskContext host if needed

### Densidade
Judgment +40

### Fora de escopo
Core scores · invent 0 · density peels · tipografia

### §5
nenhum

## DoD produto (≥5)
- [ ] packFacts score_state productWord
- [ ] unmeasured absence (never invent 0)
- [ ] paired delta only when both arms published
- [ ] partial/regressed honesty
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
fabricate 0 · micro · Core

## Plano W3
1. packFacts 2. wire Score 3. gates 4. CODEMAP DONE

## Proof
1. no engine → unmeasured absence
2. partial coverage → partial
3. pair published → delta fact
4. DEVICE_PENDING

## Council
Last major Arena judgment sans pack after 157/166/171.

### Why full-bar
≥5 files · ≥120 design · DoD≥5

### Rejection
rename state only

### Related
WAVE-021 score grammar · WAVE-157 organ pack

### Sequence after
await A

### Acceptance
Build green

### W2/W3
Wire · DONE · compress · regen · LEDGER

---

## Appendix — pack shape

```
facts:
- score_state: published|partial|unmeasured|regressed
- score_composite: N
- score_delta_atlas: +X
absences:
- par com/sem Atlas incompleto — sem Δ inventado
- Resultados ausentes nunca como zero
```

## Appendix — non-goals
Do not change Results UI.

## Appendix — risk
Primary engine nil — unmeasured honest.

## Appendix — test matrix

| case | state |
|---|---|
| nil engine | unmeasured |
| partial claim | partial |
| full pair | published + delta |

## Appendix — commit
`feat(ui): WAVE-181 arena score judgment pack wire`

## Appendix — god
state ≡ pack productWord

## Appendix — dual A
—

## Appendix — density
<200 Judgment

## Appendix — a11y
unchanged

## Appendix — idle
product pack not MARK
