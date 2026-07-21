# WAVE-182 — radar-attention-pack-and-arena-score-host-dedupe

**Status:** design · proposed · high
**Wave:** WAVE-182-radar-attention-pack-and-arena-score-host-dedupe
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 180–181
**Δ patamar:** **high**

## Problema
1. **Radar:** `AtlasCodeRadarJudgment.topAttention` ranks frota for UI and
   AskContext **hand-rolls** `top_attention` / repos_scanned facts — no
   `packFacts`. Agent dialect is host string soup, not Judgment sovereignty.
2. **Arena:** WAVE-181 wired `ArenaScoreJudgment.packFacts` for primary
   engine, but host `ArenaPremiumAskContext.facts` still **duplicates**
   motor / índice / sem_atlas / com_atlas / multiplicador / cobertura
   parcial — pack noise + dual dialect.

## Patamar
| Antes | Depois |
|---|---|
| Radar attention hand-roll | RadarJudgment.packFacts · Ask wire |
| Arena engine twice | Host anchors + cobertura_texto; score organ owns numbers |
| ≤5s frota pack | score_state + top_attention product words |

Δ = Radar attention pack sovereignty + Arena pack honesty (one law).

## Arquitetura
Casca only · zero Core · zero new surface.

### Fluxo
```
AtlasCodeRadarAskContext.facts
  → AtlasCodeRadarJudgment.packFacts(workspace, issuesBySlug, headline)
  → remove hand-roll top_attention / repos counts

ArenaPremiumAskContext.facts
  → keep tela/aba anchors + engine anchor + cobertura_texto
  → drop duplicate engine score lines (Score organ WAVE-181 owns)
```

### Arquivos (≥5)
1. AtlasCodeRadarJudgment.swift — packFacts
2. AtlasCodeRadarAskContext.swift — wire + delete hand-roll
3. ArenaPremiumAskContext.swift — host score dedupe
4. CODEMAP.md
5. design · compress · DONE · LEDGER

### Densidade
Judgment +50 · Ask hosts ↓LOC net

### Fora de escopo
Core scan · invent issues · density peels · tipografia · Search rework

### §5
nenhum

## DoD produto (≥5)
- [ ] RadarJudgment.packFacts external caller (AskContext)
- [ ] top_attention facts from Judgment rank only
- [ ] repos_scanned / quiet absence honest
- [ ] Arena host no duplicate composite/sem/com/multi lines
- [ ] cobertura_texto + engine anchor retained on Arena host
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
micro rename · invent scans · re-rank Core · tipografia

## Plano W3
1. Radar packFacts 2. Wire Ask 3. Arena host dedupe 4. gates 5. CODEMAP DONE

## Proof
1. empty scan → quiet absence
2. issues present → top_attention slugs
3. Arena pack has score_engine once (not motor+score_engine dual soup)
4. DEVICE_PENDING

## Council
Post-181 dual dialect cleanup + last Radar Judgment sans packFacts.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · product pack honesty · not idle MARK

### Rejection
Arena dedupe alone as “WAVE” without Radar · rename-only

### Related
WAVE-181 score pack · WAVE-162 radar screen · WAVE-024 topAttention

### Sequence after
await A

### Acceptance
Build green · DEVICE_PENDING

### W2/W3
Wire · dedupe · CODEMAP · DONE · compress · regen · LEDGER protect

---

## Appendix — radar pack shape

```
facts:
- radar_repos_scanned: N
- radar_repos_with_sem_retorno: M
- radar_top: slug · count
absences:
- frota quieta neste load
```

## Appendix — arena host after

```
facts:
- aba/tela
- cobertura_texto
- (organs: live + score pack)
anchors:
- engine: Name
```

## Appendix — non-goals
Do not change Radar UI rank. Do not invent score 0.

## Appendix — risk
cobertura_texto is host-only (model text) — keep outside score pack.

## Appendix — test matrix

| case | expect |
|---|---|
| radar empty scan | absence quiet |
| radar issues | top_attention |
| arena no engine | score unmeasured only once |
| arena engine | score_* from organ, not motor/indice host |

## Appendix — commit
`feat(ui): WAVE-182 radar attention pack and arena score host dedupe`

## Appendix — god
One law Radar attention · one law Arena score numbers

## Appendix — dual A
—

## Appendix — density
Hosts thinner after dedupe

## Appendix — a11y
unchanged

## Appendix — idle
Dedupe is product honesty residual, not fuse factory
