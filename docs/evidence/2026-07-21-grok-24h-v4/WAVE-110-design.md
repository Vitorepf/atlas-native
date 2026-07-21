# WAVE-110 — live-now-row-spoken-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-110-live-now-row-spoken-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after IDLE · fila vazia · 107 runner-up home live)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `LiveNowRow` hosta spoken running/paused/finished/clock/formatClock
  fora do `LiveNowJudgment` (já tem section/pack/rank).
- Residual Continuity/Home live dialect pós-spoken wipe global.
- WAVE-107 council named home-live-now-row-spoken as residual.

## Patamar

| Antes | Depois |
|---|---|
| Row spoken methods | **LiveNowJudgment** spokenRow family |
| formatClock on View | Judgment pure clock |
| Section already Judgment | Row parity |

Δ = **soberania do spoken da sessão viva** na Home/hub.

---

## Arquitetura

### Princípios

- Casca only. LiveSessionSnapshot published.
- Never invent elapsed when nil.
- Zero Core.

### Fluxo

```
session · hub index · now
  → LiveNowJudgment.spokenRow · formatClock · pauseAge
  → LiveNowRow thin wire
```

### Arquivos (≥5)

1. LiveNowJudgment.swift  
2. LiveNowRow.swift  
3. LiveNowSection.swift (optional section already Judgment)  
4. CODEMAP  
5. design + compress  

### Densidade

Judgment +100 · Row −80 spoken soup

### Fora de escopo

- App Group Continuity data  
- Tipografia  
- Rank rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] spokenRow/running/paused/finished on Judgment.  
- [ ] formatClock + spokenClock pure.  
- [ ] pauseAgeHours + clock a11y on Judgment.  
- [ ] LiveNowRow wires Judgment only for spoken.  
- [ ] Section spoken remains Judgment.  
- [ ] Gates + CODEMAP + DEVICE_PENDING.  

## Anti-objetivos

- inventar timer  
- tipografia  

## Plano W3

1. Extend Judgment.  
2. Thin Row.  
3. CODEMAP.  
4. Gates.

## Proof

1. Running + clock → “há …”.  
2. Paused long → hours age.  
3. Remote suffix present.  
4. DEVICE_PENDING.

## Council

107 residual home live row. Completes Continuity spoken organ.

### Why full-bar

- ≥5 files · product live row · DoD≥5 · design ≥120  

---

*End WAVE-110 design.*
