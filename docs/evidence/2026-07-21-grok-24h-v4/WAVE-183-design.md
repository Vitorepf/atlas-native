# WAVE-183 — radar-workspace-shell-pack-and-livenow-packfacts

**Status:** design · proposed · high
**Wave:** WAVE-183-radar-workspace-shell-pack-and-livenow-packfacts
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 182
**Δ patamar:** **high**

## Problema
1. **Radar Ask** still hand-rolls workspace shell facts (folders/recents/
   workspace_root/wire_fallback) outside Judgment — attention pack (182)
   closed scan dialect but **catalog shell** remains host soup.
2. **LiveNowJudgment.packLiveAnchors** is pack sovereignty with non-canonical
   name (only pack* not named packFacts) — Home Ask uses it; GOD rename
   honesty (canon §7.3) + packFacts alias for agent discovery.

## Patamar
| Antes | Depois |
|---|---|
| Radar shell hand-roll | RadarJudgment.packWorkspaceFacts |
| packLiveAnchors only | packFacts + packLiveAnchors shim |
| Dual discovery names | One law packFacts for IA |

Δ = Radar catalog shell pack + LiveNow pack naming GOD.

## Arquitetura
Casca only.

### Fluxo
```
AtlasCodeRadarJudgment.packWorkspaceFacts(workspace?)
  → RadarAskContext.facts wires shell + attention + screen

LiveNowJudgment.packFacts(...) == former packLiveAnchors
  → HomeAskContext uses packFacts
  → packLiveAnchors remains thin shim (compat)
```

### Arquivos (≥5)
1. AtlasCodeRadarJudgment.swift — packWorkspaceFacts
2. AtlasCodeRadarAskContext.swift — wire shell
3. LiveNowJudgmentRow.swift (or LiveNowJudgment) — packFacts rename
4. HomeAskContext.swift — call packFacts
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
wire + rename · ↓LOC hand-roll

### Fora de escopo
Core · invent workspace · density peels · tipografia

### §5
nenhum

## DoD produto (≥5)
- [ ] packWorkspaceFacts external caller
- [ ] folders/recents/root/absence honest
- [ ] LiveNow.packFacts used from HomeAsk
- [ ] packLiveAnchors shim preserves callers
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
break Home pack · invent roots · micro rename alone without Radar

## Plano W3
1. packWorkspaceFacts 2. wire Radar 3. LiveNow packFacts 4. Home 5. gates CODEMAP DONE

## Proof
1. nil workspace → absence
2. root present → workspace_root
3. Home live packFacts face productWord
4. DEVICE_PENDING

## Council
Closes last Radar Ask hand-roll + pack naming honesty.

### Why full-bar
≥5 files · ≥120 design · DoD≥5

### Rejection
shim-only rename without Radar shell

### Related
WAVE-182 attention · WAVE-064 LiveNow pack

### Sequence after
await A

### Acceptance
Build green

### W2/W3
Wire · rename · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — workspace pack shape

```
facts:
- radar_folders: N
- radar_recents: M
- radar_workspace_root: path
absences:
- workspace wire nil
- sem root nem recentes
```

## Appendix — LiveNow

```
packFacts(...) -> (facts, anchors, absences)
packLiveAnchors = packFacts  // shim
```

## Appendix — non-goals
UI rank change · Core workspace DTO

## Appendix — risk
Shim must keep Home compile

## Appendix — test matrix

| case | expect |
|---|---|
| nil ws | absence |
| root set | root fact |
| home live | packFacts works |

## Appendix — commit
`feat(ui): WAVE-183 radar workspace pack and LiveNow packFacts`

## Appendix — god
packFacts discovery · one shell law

## Appendix — dual A
—

## Appendix — density
Ask thinner

## Appendix — a11y
unchanged

## Appendix — idle
Not MARK-only
