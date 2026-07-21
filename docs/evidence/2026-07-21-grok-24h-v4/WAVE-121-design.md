# WAVE-121 — plan-card-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-121-plan-card-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `PlanCard.swift` **424 LOC** misturava host · body sections · FlexWrap ·
  FlowChips.
- Residual density plan card pós-spoken-105.

## Patamar

| Antes | Depois |
|---|---|
| 424 monólito | **2 peels** host · body/layout |

Δ = **densidade do plan card**.

---

## Arquitetura

### Layout

```
PlanCard.swift       host shell
PlanCardBody.swift   body sections · FlexWrap · FlowChips
```

### Arquivos (≥5)

peels · CODEMAP · design · compress · LEDGER

### Densidade

Each ≤250.

### Fora de escopo

- Core · tipografia · Judgment  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Host peel.  
- [ ] Body peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates.  
- [ ] DEVICE_PENDING.  

## Anti-objetivos

- inventar plan  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l`. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after Search-120.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-121 design.*
