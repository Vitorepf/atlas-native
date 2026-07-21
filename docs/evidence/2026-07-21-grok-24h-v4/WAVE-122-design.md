# WAVE-122 — workspace-surface-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-122-workspace-surface-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `WorkspaceSurface.swift` **389 LOC** misturava WorkspaceView chrome ·
  ThreadsSection · ThreadLink.
- Residual density workspace surface.

## Patamar

| Antes | Depois |
|---|---|
| 389 monólito | **2 peels** Surface · Body/threads |

Δ = **densidade do workspace surface**.

---

## Arquitetura

### Layout

```
WorkspaceSurface.swift      WorkspaceView host peels
WorkspaceSurfaceBody.swift  ThreadsSection · ThreadLink
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

- [ ] Surface peel.  
- [ ] Body peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates.  
- [ ] DEVICE_PENDING.  

## Anti-objetivos

- inventar workspace  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l`. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after PlanCard-121.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-122 design.*
