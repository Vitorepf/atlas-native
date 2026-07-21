# WAVE-117 — live-timeline-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-117-live-timeline-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `LiveTimeline.swift` **412 LOC** misturava timeline host + NarrativeRow
  model + NarrativeRowView.
- Residual density Continuity timeline.

## Patamar

| Antes | Depois |
|---|---|
| 412 monólito | **3 peels** timeline / row model / row view |

Δ = **densidade da timeline viva**.

---

## Arquitetura

### Layout

```
LiveTimeline.swift                    host + projection
LiveTimelineNarrativeRow.swift        row model
LiveTimelineNarrativeRowView.swift    row view
```

### Arquivos (≥5)

peels · CODEMAP · design · compress

### Densidade

Host ≤320 · rows thin.

### Fora de escopo

- Core · tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Host peel.  
- [ ] NarrativeRow model peel.  
- [ ] NarrativeRowView peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- inventar narrative  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l`. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after TurnPresence-116.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-117 design.*
