# WAVE-078 — workspace-empty-editorial-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-078-workspace-empty-editorial-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after WAVE-073 screen)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `WorkspaceEditorialEmpty` owns headline/footnote/spoken for empty
  filter · free-only · titled workspace **without pure Judgment**.
- WAVE-073 closed workspace **screen** face; residual **editorial empty
  organ** still dialect soup in WorkspaceEmptyStates.
- Pack cannot reuse `workspace_empty_face: area|free|workspace`.

## Patamar

| Antes | Depois |
|---|---|
| if area/free soup | Exclusive empty face |
| Copy local | Judgment headline/footnote/spoken |
| No pack | Pack face + area + freeOnly |

Δ = **soberania do vazio editorial** — filtro ≠ free ≠ workspace.

---

## Arquitetura

### Princípios

- Casca only; area + freeOnly + screenTitle published.
- Honesty: empty never invents threads.
- One domain: workspace editorial empty (not screen load).

### Fluxo

```
area + freeOnly + screenTitle
  → WorkspaceEmptyJudgment.face / headline / footnote / spoken / pack
  → WorkspaceEditorialEmpty peels
```

### Arquivos (≥5)

- `WorkspaceEmptyJudgment.swift` (**new**)
- `WorkspaceEmptyStates.swift`
- CODEMAP · design · compress

### Densidade

Judgment 120–240.

### Fora de escopo

- Core threads  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: area · free · workspace.
2. headline/footnote/spoken from Judgment.
3. Pack face + area label.
4. accessibilityValue productWord.
5. Gates + CODEMAP.
6. DEVICE_PENDING.

## Anti-objetivos

- invent threads  
- fuse WorkspaceScreenJudgment file  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire EmptyStates  
3. CODEMAP · compress  

Estimativa: **5 files · 180–300 LOC**.

## Proof

1. area != tudo → area face.  
2. freeOnly → free face.  
3. else workspace face.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Empty residual after screen 073. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-078 design.*
