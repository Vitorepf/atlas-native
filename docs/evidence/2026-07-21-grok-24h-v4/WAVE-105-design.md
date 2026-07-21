# WAVE-105 — plan-card-spoken-judgment-completion

**Status:** design · proposed  
**Wave:** `WAVE-105-plan-card-spoken-judgment-completion`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `PlanJudgment` já tem face/pack/spokenCard/step/audit, mas **PlanCard**
  ainda hosta shims e dialeto local: `spokenChipRow`, `spokenPlanDetail`,
  `spokenRevisionToggle`, wrappers que só repassam Judgment.
- Casca do plano de obra com grammar partida entre host e Judgment.
- Residual pós-spoken wipe global: Plan organ incompleto.

## Patamar

| Antes | Depois |
|---|---|
| PlanCard spoken extensions | **PlanJudgment only** |
| Chip/detail/revision local | Judgment spoken family |
| Wrapper methods | Views call Judgment static |

Δ = **soberania total do spoken do plano** no órgão Judgment.

---

## Arquitetura

### Princípios

- Casca only. Plan/progress from published bubble fields.
- Delete thin wrappers on PlanCard.
- Zero Core.

### Fluxo

```
plan · progress · chips · revisions
  → PlanJudgment spoken*
  → PlanCard / RevisionBody / StepRow wire
```

### Arquivos (≥5)

1. PlanJudgment.swift  
2. PlanCard.swift  
3. PlanCardRevisionBody.swift (if needed)  
4. PlanCardStepRow.swift (if needed)  
5. CODEMAP  
6. design + compress  

### Densidade

Judgment +60 · PlanCard −50 wrappers

### Fora de escopo

- Core plan DTO  
- Tipografia  
- New plan UI  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] spokenChipRow / spokenPlanDetail / spokenRevisionToggle on Judgment.  
- [ ] spokenDetailToggle (show tools/gates).  
- [ ] Delete PlanCard spoken extension shims.  
- [ ] All a11y labels Judgment-only.  
- [ ] packFacts unchanged honesty.  
- [ ] Gates + CODEMAP + DEVICE_PENDING.  

## Anti-objetivos

- inventar steps  
- tipografia  

## Plano W3

1. Extend PlanJudgment.  
2. Rewire PlanCard*.  
3. Delete wrappers.  
4. CODEMAP.  
5. Gates.

## Proof

1. Chip row spoken includes count + items.  
2. Detail spoken lists agents/tools/gates only when present.  
3. Revision toggle expanded/collapsed.  
4. No PlanCard.spoken* methods remain.  
5. DEVICE_PENDING.

## Council

Residual after Autônomos-104 dialect wipe. Plan organ completion.

### Rejection

Wrappers remain → fail.

### Spoken map

| Helper | Seed |
|---|---|
| spokenChipRow | label, N itens, items… |
| spokenPlanDetail | agentes/ferramentas/gates |
| spokenRevisionToggle | comparar versões… |
| spokenDetailToggle | mostrar/ocultar ferramentas… |

### Why full-bar

- Multi-file · completes Plan organ · DoD≥5 · ≥120 design  

---

*End WAVE-105 design.*
