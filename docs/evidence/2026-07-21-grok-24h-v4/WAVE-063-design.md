# WAVE-063 — change-review-sheet-load-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-063-change-review-sheet-load-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after risk judgment)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ChangeReviewSheet` spoken load/unavailable/ready paths live as View
  helpers **without pure Judgment** for the sheet organ.
- Loading vs unavailable vs ready vs empty-surface (no patches/checks)
  are easy to confuse; pack hosts cannot reuse
  `review_sheet_face: loading|unavailable|ready|empty`.
- Residual after ChangeReviewJudgment risk/rank (patches/findings) and
  host peels: **sheet load honesty** still dialect on View/Sections.

## Patamar

| Antes | Depois |
|---|---|
| Bool loadFinished soup | Exclusive sheet face |
| Spoken local | Judgment spoken |
| Content nil branches only | Face + unavailable chrome |
| No pack | Pack face + surface flags |

Δ = **soberania da folha de revisão** — consultando ≠ falha ≠ vazia ≠ pronta.

---

## Arquitetura

### Princípios

- Casca only; `loadFinished` + `review?` + hasReviewSurface already.
- Honesty: unavailable never invents review body; empty surface uses
  published hasReviewSurface (patches/controls/tests/findings).
- One domain: change-review sheet load organ.

### Fluxo

```
loadFinished + review? + hasSurface
  → ChangeReviewSheetJudgment.face / spoken / pack
  → ChangeReviewSheet peels
```

### Arquivos (≥5)

- `ChangeReviewSheetJudgment.swift` (**new**)
- `ChangeReviewSections.swift`
- `ChangeReviewView.swift` (wire a11y value if needed)
- CODEMAP
- design + compress

### Densidade

Judgment 130–260.

### Fora de escopo

- Core change-review API  
- Accept/reject mutation logic  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: loading · unavailable · empty · ready.
2. Spoken sheet from Judgment.
3. empty = review present but !hasReviewSurface.
4. ready = review present + has surface.
5. Pack face + absences.
6. accessibilityValue = productWord on sheet.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent review  
- fuse with RiskStrip judgment domain incorrectly  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire sheet spoken + content gate optional  
3. CODEMAP · compress  

Estimativa: **5–6 files · 200–320 LOC**.

## Proof

1. !loadFinished + nil → loading.  
2. loadFinished + nil → unavailable.  
3. review empty surface → empty.  
4. review with patches → ready.  
5. DEVICE_PENDING.

## Council

Empty QUEUE. Sheet load residual real. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-063 design.*
