# WAVE-044 — live-timeline-narrative-face-instrument

**Status:** design · proposed  
**Wave:** `WAVE-044-live-timeline-narrative-face-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `LiveTimeline` (~542 LOC) has filter chips + rows + filter-silence
  surface, but **no pure Judgment** for exclusive narrative face.
- Spoken section is **count-only**; filter silence spoken is separate
  dialect not unified with a face product word.
- Operator cannot judge in ≤5s whether the instrument is **live**,
  **filter-silenced**, or **empty** with one grammar shared by a11y +
  future pack hosts.
- **Chronology is sacred** — this wave does **not** re-rank rows
  (anti-objetivo). Face only.
- Residual after execution phase (022–027) and plan (040): mid-run
  **narrative organ** still View-owned without face grammar.

## Patamar

| Antes | Depois |
|---|---|
| Count-only section spoken | Face: empty / live / filterSilence |
| Silence surface ad hoc | Judgment-owned face + spoken |
| No pack | pack facts for step styles |
| A11y scattered | productWord + spokenFace |

Δ = **soberania da narrativa viva** — saber se o filtro calou a obra.

---

## Arquitetura

### Princípios

- Casca only; activities already on bubble.
- **Never re-order** narrative rows (chrono / filter apply stays).
- Face from baseRows + filter + filtered rows only.
- Density: Judgment pure · thin optional face line · LiveTimeline 1 domain.

### Fluxo

```
activities → narrativeRows (unchanged)
  → filter.apply
  → LiveTimelineNarrativeJudgment.face(base, filtered, filter)
  → optional face kicker under chips
  → spoken section uses Judgment
  → pack for host if needed
```

### Módulos

| Nome | Papel |
|---|---|
| `LiveTimelineNarrativeJudgment` | face · summary · pack · spoken |
| LiveTimeline | wire face + spoken |
| A11yID | liveTimelineFace |
| CODEMAP | narrative face |

### Arquivos (≥5)

- `LiveTimelineNarrativeJudgment.swift` (**new**)
- `LiveTimeline.swift`
- `A11yID.swift`
- `CODEMAP.md`
- design + compress

May add thin face chrome inline in LiveTimeline (same file) if strip would be peel spam — still ≥5 files with evidence.

### Densidade

Judgment 200–500 · Timeline stays 1 domain · no chrono rank.

### Fora de escopo

- Re-rank rows by attention  
- Core activity DTO  
- Island phase rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: empty · live(N) · filterSilence(filter, total).
2. Chrono order of rows **unchanged**.
3. Section spoken uses Judgment face.
4. Filter silence surface spoken aligns to face.
5. Optional thin face label when live/silence (not empty).
6. Pack facts: face + intent/tool counts from base rows.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- re-rank timeline  
- invent activities  
- fuse into ExecutionProof  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire spoken + face chrome  
3. A11y + CODEMAP  
4. compress · DONE · regen  

Estimativa: **5–7 files · 250–400 LOC**.

## Proof

1. Activities live → face live N.  
2. Filter tools with zero tools → filterSilence.  
3. Empty activities → empty (host may hide).  
4. Row order identical pre/post.  
5. DEVICE_PENDING.

## Council

Post-043 empty queue. Narrative residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-044 design.*
