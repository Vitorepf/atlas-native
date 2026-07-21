# WAVE-115 — root-chrome-routes-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-115-root-chrome-routes-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `RootChromeFace.swift` **430 LOC** mistura domain dispatch · conversation
  destinations · lifecycle modifiers.
- Residual density pós-111–114 peel pattern.

## Patamar

| Antes | Depois |
|---|---|
| 430 monólito | **3 peels** Face dispatch / Conversation routes / Lifecycle |

Δ = **densidade do root chrome de rotas**.

---

## Arquitetura

### Princípios

- Casca only. Zero Core.
- Same domain Root*.

### Layout

```
RootChromeFace.swift                 domain destination dispatch
RootChromeConversationRoutes.swift   conversa/new/thread/workspace dest
RootChromeLifecycle.swift            lifecycle modifiers
```

### Arquivos (≥5)

1–3 peels · CODEMAP · design · compress

### Densidade

Each ≤220.

### Fora de escopo

- Core  
- New routes  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Face dispatch peel.  
- [ ] Conversation routes peel.  
- [ ] Lifecycle peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- inventar rotas  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l` ≤220. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after Radar-114.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-115 design.*
