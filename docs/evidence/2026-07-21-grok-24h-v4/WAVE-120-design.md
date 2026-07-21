# WAVE-120 — search-surface-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-120-search-surface-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `SearchSurface.swift` **426 LOC** misturava SearchView/Header + results/
  miss/thread link.
- Residual density search surface.

## Patamar

| Antes | Depois |
|---|---|
| 426 monólito | **2 peels** Surface/Header · Results |

Δ = **densidade da busca**.

---

## Arquitetura

### Layout

```
SearchSurface.swift         SearchView + Header
SearchSurfaceResults.swift  results · miss · thread link
```

### Arquivos (≥5)

peels · CODEMAP · design · compress · LEDGER

### Densidade

Each ≤230.

### Fora de escopo

- Core · tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Surface/Header peel.  
- [ ] Results peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates.  
- [ ] DEVICE_PENDING.  

## Anti-objetivos

- inventar search  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l`. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after sheets-119.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-120 design.*
