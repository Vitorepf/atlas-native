# WAVE-187 — code-graph-identity-and-arena-live-measurement-pack

**Status:** design · proposed · high
**Wave:** WAVE-187-code-graph-identity-and-arena-live-measurement-pack
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 186
**Δ patamar:** **high**

## Problema
1. **AtlasCodeAskContext** still hand-rolls graph identity (trunk · head ·
   trunk_head · commits_loaded · sem_retorno_signals · phase) while screen/
   slice/health/row packs exist — dual dialect for identity.
2. **ArenaPremiumAskContextLive** still hand-rolls measurement presentation
   (progresso · primary corrida line · alertas · narrativa · corridas_live
   list) after now/live/status/pipeline packs — residual organ soup.

## Patamar
| Antes | Depois |
|---|---|
| Code identity hand-roll | GraphJudgment.packIdentityFacts |
| Arena measurement hand-roll | LiveControlJudgment.packMeasurementFacts |
| dual discovery | one law packFacts |

Δ = code identity + arena measurement pack sovereignty.

## Arquitetura
Casca only · published graph DTO + live presentation only.

### Fluxo
```
AtlasCodeGraphJudgment.packIdentityFacts(model)
  → CodeAsk replaces trunk/head/commits/phase hand-roll

ArenaLiveControlJudgment.packMeasurementFacts(...)
  → Arena Live organ replaces progress/alerts/narrative/list hand-roll
```

### Arquivos (≥5)
1. AtlasCodeGraphJudgment.swift — packIdentityFacts
2. AtlasCodeAskContext.swift — wire
3. ArenaLiveControlJudgment.swift — packMeasurementFacts
4. ArenaPremiumAskContextLive.swift — wire
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
Judgments +50–80 each · hosts ↓LOC

### Fora de escopo
Core · invent trunk · density peels · tipografia

### §5
dual-count obra/branch already absent honesty — keep

## DoD produto (≥5)
- [ ] packIdentityFacts external caller
- [ ] trunk/head/commits/phase honest absences
- [ ] packMeasurementFacts external caller
- [ ] progress/alerts/narrative/list not host soup
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
invent head · invent alerts · micro · Core

## Plano W3
1. identity pack 2. wire Code 3. measurement pack 4. wire Arena Live 5. gates CODEMAP DONE

## Proof
1. empty graph → commits absence
2. trunk nil → absence
3. progress published → progresso fact
4. no live runs on execution → absence
5. DEVICE_PENDING

## Council
Last major Code/Arena host hand-rolls after shell campaign 185–186.

### Why full-bar
≥5 files · ≥120 design · DoD≥5

### Rejection
identity alone without measurement · MARK-only

### Related
WAVE-161 graph screen · WAVE-157 arena organs · WAVE-186 arena shell

### Sequence after
await A

### Acceptance
Build green

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — identity pack

```
facts:
- graph_trunk / graph_head / graph_trunk_head
- graph_commits_loaded
- graph_sem_retorno_signals
- graph_phase: loading|failed|loaded
absences:
- trunk não publicado
- grafo sem nós
```

## Appendix — measurement pack

```
facts:
- measurement_progress: c/t remaining
- measurement_primary: suite · arm · status
- measurement_alerts: N
- measurement_narrative: …
- measurement_live_runs: N
- measurement_live: suite · arm · status
absences:
- nenhuma corrida live
```

## Appendix — non-goals
Re-rank live · invent report narrative

## Appendix — risk
narrative is report text published — include only if non-empty

## Appendix — test matrix

| case | expect |
|---|---|
| loading phase | graph_phase loading |
| progress nil | no progresso fact |
| alerts 0 | nenhuma exceção |

## Appendix — commit
`feat(ui): WAVE-187 code-graph identity and arena live measurement pack`

## Appendix — god
one law identity · one law measurement

## Appendix — dual A
—

## Appendix — density
hosts thinner

## Appendix — a11y
unchanged

## Appendix — idle
product pack not MARK
