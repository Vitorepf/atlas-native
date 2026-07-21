# WAVE-075 — live-timeline-filter-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-075-live-timeline-filter-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual timeline filter)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `LiveTimelineA11y` filter chips + filter-silence surface spoken are
  View-local **without pure Judgment** for the filter organ.
- Narrative face already WAVE-044; residual **read-filter organ**
  (active/silent chips · silence surface) still dialect soup.
- Pack cannot reuse `timeline_filter_face: open|active|silent`.

## Patamar

| Antes | Depois |
|---|---|
| Spoken helpers only | Exclusive filter face |
| Silence surface local | Judgment spoken |
| No pack for filter | Pack face + filter id |

Δ = **soberania do filtro de leitura** — chrono sagrado; filtro só leitura.

---

## Arquitetura

### Princípios

- Casca only; TimelineReadFilter published; **chrono order unchanged**.
- Honesty: silent filter = no invent rows; silence surface honest.
- One domain: timeline read filter (not narrative face).

### Fluxo

```
filter + step counts + silent?
  → LiveTimelineFilterJudgment.face / spoken / pack
  → LiveTimeline peels
```

### Arquivos (≥5)

- `LiveTimelineFilterJudgment.swift` (**new**)
- `LiveTimeline.swift`
- CODEMAP · design · compress

### Densidade

Judgment 130–250.

### Fora de escopo

- Reorder chrono  
- Core timeline  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: open · active · silent (per chip context).
2. spoken chip/silence/section peels from Judgment where applicable.
3. Chrono order untouched (rg / design note).
4. Pack filter + silence.
5. accessibilityValue on silence surface.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent events  
- reorder timeline  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire LiveTimelineA11y  
3. CODEMAP · compress  

Estimativa: **5 files · 200–320 LOC**.

## Proof

1. filter silent → silent face.  
2. active chip spoken selected.  
3. chrono order same.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Filter residual after narrative. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-075 design.*
