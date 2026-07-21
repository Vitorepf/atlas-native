# WAVE-073 — workspace-screen-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-073-workspace-screen-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual Workspace shell)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `WorkspaceView` spoken shell (loading · offline · empty filter · list)
  is View-local **without pure Judgment**.
- Pack cannot reuse `workspace_face: loading|offline|empty|list`.
- Residual after Search screen (071) + thread rank: **workspace screen
  organ** still dialect soup.

## Patamar

| Antes | Depois |
|---|---|
| Spoken helper local | Exclusive workspace face |
| Empty copy local | Judgment empty/list honesty |
| No pack | Pack face + counts + area |

Δ = **soberania da lista de conversas do workspace**.

---

## Arquitetura

### Princípios

- Casca only; loading/failure/threads published.
- Honesty: empty filter ≠ invent threads.
- One domain: workspace screen (not thread rank).

### Fluxo

```
loading? + offline? + threadCount + area + title
  → WorkspaceScreenJudgment.face / spoken / pack
  → WorkspaceSurface peels
```

### Arquivos (≥5)

- `WorkspaceScreenJudgment.swift` (**new**)
- `WorkspaceSurface.swift`
- optional WorkspaceEmptyStates peel
- CODEMAP · design · compress

### Densidade

Judgment 130–250.

### Fora de escopo

- Core threads API  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: loading · offline · empty · list(N).
2. Spoken screen from Judgment.
3. Hint freeOnly vs workspace from Judgment.
4. Pack face + n + area.
5. accessibilityValue productWord.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent threads  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Surface  
3. CODEMAP · compress  

Estimativa: **5–6 files · 200–320 LOC**.

## Proof

1. loading → loading.  
2. offline → offline.  
3. empty filter → empty.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Workspace residual after Search. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-073 design.*
