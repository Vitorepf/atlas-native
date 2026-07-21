# WAVE-118 — commit-row-body-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-118-commit-row-body-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeCommitRowBody.swift` **417 LOC** de extensions de meta/layout
  no mesmo arquivo.
- Residual density grafo/commit row após Judgment spoken-110 era.

## Patamar

| Antes | Depois |
|---|---|
| 417 monólito | **2 peels** Body · Meta |

Δ = **densidade do body da commit row**.

---

## Arquitetura

### Layout

```
AtlasCodeCommitRowBody.swift   lead/layout peels
AtlasCodeCommitRowMeta.swift   meta/tip/branch peels
```

### Arquivos (≥5)

peels · CODEMAP · design · compress · LEDGER

### Densidade

Each ≤230.

### Fora de escopo

- Core · tipografia · Judgment rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Body ≤220.  
- [ ] Meta peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates.  
- [ ] DEVICE_PENDING.  

## Anti-objetivos

- inventar commit  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l`. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after LiveTimeline-117.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-118 design.*
