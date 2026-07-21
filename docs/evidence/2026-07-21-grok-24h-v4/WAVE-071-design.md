# WAVE-071 — search-screen-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-071-search-screen-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual Search shell)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `SearchView` spoken shell/results (loading · offline · recent · query)
  live View-local **without pure Judgment**.
- Pack hosts cannot reuse `search_face: loading|offline|empty_recent|
  empty_query|results`.
- Residual after WorkspaceThreadJudgment rank: **search screen organ**
  still dialect soup on Surface.

## Patamar

| Antes | Depois |
|---|---|
| Spoken helper soup | Exclusive search face |
| Count strings local | Judgment spoken |
| No pack | Pack face + counts + query |

Δ = **soberania da busca** — offline ≠ vazio ≠ resultados.

---

## Arquitetura

### Princípios

- Casca only; loading/failure/results published on SearchView.
- Honesty: empty query vs empty recent distinct; no invent hits.
- One domain: search screen organ (not thread rank).

### Fluxo

```
loading? + offline? + browsingRecent + counts + query
  → SearchScreenJudgment.face / spoken / pack
  → SearchSurface peels
```

### Arquivos (≥5)

- `SearchScreenJudgment.swift` (**new**)
- `SearchSurface.swift`
- CODEMAP
- design + compress

### Densidade

Judgment 140–260.

### Fora de escopo

- Core search API  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: loading · offline · empty_recent · empty_query · results_recent · results_query.
2. Spoken screen from Judgment.
3. Hint constant on Judgment or peel.
4. Pack face + n + query?
5. accessibilityValue productWord.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent results  
- fuse thread rank  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire SearchSurface  
3. CODEMAP · compress  

Estimativa: **5 files · 200–320 LOC**.

## Proof

1. loading shell → loading.  
2. offline → offline.  
3. empty query results → empty_query.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Search residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-071 design.*
