# WAVE-058 — artifacts-preview-state-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-058-artifacts-preview-state-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArtifactPreviewState` (idle/loading/loaded/tooLarge/failed) drives the
  preview pane, but **no pure Judgment** face for product words / spoken /
  pack.
- `ArtifactViewerA11y` + pane switches are dialect soup across Chrome and
  Sheet (~435 + sheet peels).
- After list/rank judgment (041), residual **preview organ** still lacks
  exclusive face (tooLarge vs failed vs loaded).
- Operator cannot share grammar with pack hosts for "preview blocked by size".

## Patamar

| Antes | Depois |
|---|---|
| State switch only | Exclusive preview face |
| Spoken scattered | Judgment spoken |
| No pack | Pack face + item kind/size |

Δ = **soberania do preview** — tooLarge ≠ failed ≠ loaded.

---

## Arquitetura

### Princípios

- Casca only; `ArtifactPreviewState` + item already.
- Honesty: tooLarge uses published bytes; failed uses message.
- Kind labels reuse ArtifactViewer.kindLabel / byteLabel.
- One domain: artifact preview.

### Fluxo

```
preview state + selected item?
  → ArtifactPreviewJudgment.face / spoken / pack
  → ArtifactSheet pane a11y + optional chrome
```

### Arquivos (≥5)

- `ArtifactPreviewJudgment.swift` (**new**)
- `ArtifactSheet.swift`
- `ArtifactPreviewChrome.swift` (spoken reuse)
- CODEMAP
- design + compress

### Densidade

Judgment 150–350.

### Fora de escopo

- Core artifact content API  
- List rank rewrite (041)  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: idle · loading · loaded · tooLarge · failed.
2. Spoken pane from Judgment.
3. tooLarge spoken uses byteLabel honesty.
4. loaded spoken reuses kind grammar.
5. Pack face + kind + size when item known.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent content  
- re-rank list  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire sheet a11y + chrome spoken  
3. CODEMAP · compress  

Estimativa: **5–7 files · 220–360 LOC**.

## Proof

1. Loading → face loading.  
2. tooLarge → face tooLarge + bytes.  
3. failed → face failed.  
4. loaded image → face loaded.  
5. DEVICE_PENDING.

## Council

Empty QUEUE. Preview residual after 041. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-058 design.*
