# WAVE-116 — turn-presence-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-116-turn-presence-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `TurnPresence.swift` **442 LOC** misturava Live Activity · notify/tick ·
  host Entry/shared no mesmo arquivo.
- Residual density Continuity após Judgment-102 e LiveNow-110.

## Patamar

| Antes | Depois |
|---|---|
| 442 monólito | **3 peels** host / Activity / Runtime |

Δ = **densidade do TurnPresence Continuity**.

---

## Arquitetura

### Layout

```
TurnPresence.swift           Entry · shared · watch · setVisible
TurnPresenceActivity.swift   LA start/update/end/broadcast/content
TurnPresenceRuntime.swift    notify · tick · cleanup · observe
```

### Arquivos (≥5)

peels · CODEMAP · design · compress

### Densidade

Each ≤250.

### Fora de escopo

- Core · App Group restore · tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Host thin.  
- [ ] Activity peel LA.  
- [ ] Runtime peel tick/notify.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- inventar presence  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l` peels. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual Continuity after 115.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-116 design.*
