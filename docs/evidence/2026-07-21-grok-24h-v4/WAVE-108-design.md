# WAVE-108 — arena-stop-governance-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-108-arena-stop-governance-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after A 106–107 · fila vazia · council runner-up)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArenaPremiumStopSheet` é ação **governada** (actor + reason + confirm)
  mas canSubmit/valid, titles, receipt spoken e close labels ainda são
  dialeto local / magic strings.
- WAVE-107 council named stop governance as #1 runner-up after status.
- Paridade com AutonomosReasonJudgment / run sheet governance.

## Patamar

| Antes | Depois |
|---|---|
| valid local bool | **ArenaStopJudgment** face blocked/ready |
| Copy local | Judgment titles/hints/spoken |
| Receipt ad hoc | spokenReceipt + packFacts |

Δ = **soberania da parada governada** na Arena.

---

## Arquitetura

### Princípios

- Casca only. actor/reason operator input; face pure.
- Reuse tone negative / stop icon existing chrome.
- Zero Core.

### Fluxo

```
actor + reason + receipt?
  → ArenaStopJudgment
       face blocked|ready · canSubmit · spoken sheet/confirm/close
       receipt spoken · packFacts
  → StopSheet wire
```

### Arquivos (≥5)

1. ArenaStopJudgment.swift (**new**)
2. ArenaPremiumStopSheet.swift
3. CODEMAP
4. design
5. compress
6. DONE/QUEUE/LEDGER

### Densidade

Judgment ~120–200 · Sheet thinner

### Fora de escopo

- Core stop API  
- Pipeline fuse  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] face blocked/ready from actor+reason pure.  
- [ ] canSubmit pure.  
- [ ] spoken sheet / confirm / close / fields on Judgment.  
- [ ] receipt spoken when lastStop matches measurement.  
- [ ] packFacts stop_face + optional.  
- [ ] Gates + CODEMAP + DEVICE_PENDING.  

## Anti-objetivos

- inventar parada  
- tipografia  

## Plano W3

1. New Judgment.  
2. Wire StopSheet.  
3. CODEMAP.  
4. Gates.  

## Proof

1. Empty actor → blocked face, confirm disabled.  
2. Actor+reason → ready.  
3. Receipt VO after stop.  
4. DEVICE_PENDING.

## Council

107 runner-up #1 stop governance.

### Rejection

Only rename valid → fail.

### Why full-bar

- New organ · ≥5 files · product governance · DoD≥5 · design ≥120  

---

*End WAVE-108 design.*
