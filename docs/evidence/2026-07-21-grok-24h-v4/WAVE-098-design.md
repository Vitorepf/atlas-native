# WAVE-098 — autonomos-governed-reason-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-098-autonomos-governed-reason-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AutonomosReasonSheet` é a **folha de governança** (actor + motivo
  auditável) usada em decisões e transfer — mas **canSubmit**, spoken
  sheet/confirm/cancel e section titles ainda são dialeto local.
- Transfer/Decision passam titles/explainers de Judgments irmãos, mas
  a sheet não tem face `blocked | ready` nem pack `reason_face`.
- Residual pós-hub-096 / can_do-088: governança de ação sem órgão.

## Patamar

| Antes | Depois |
|---|---|
| canSubmit local | **AutonomosReasonJudgment** face |
| Spoken soup | Judgment spoken family |
| Sem pack | pack reason_face + optional |

Δ = **soberania da confirmação governada** — actor/motivo/ready uma língua.

---

## Arquitetura

### Princípios

- Casca only. Actor/reason strings are operator input; face is pure.
- Reuse Transfer.reasonTitle/explainer; Decision pending titles.
- Zero Core.

### Fluxo

```
actor + reason + reasonOptional
  → AutonomosReasonJudgment
       face blocked | ready
       spoken sheet · confirm · cancel · hints
  → AutonomosReasonSheet wire
  → pack optional
```

### Arquivos

- `AutonomosReasonJudgment.swift` (**new**)
- `AutonomosReasonSheet.swift`
- `AutonomosDecisionSurface.swift` (thin if needed)
- CODEMAP
- design/compress

### Densidade

Judgment 120–250 · Sheet thin

### Fora de escopo

- Core ledger write  
- New decision types  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] face blocked|ready exclusive product words.
- [ ] canSubmit pure from Judgment.
- [ ] spoken sheet/confirm/cancel/hints from Judgment.
- [ ] section titles/placeholders from Judgment.
- [ ] Pack reason_face + optional absence.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar actor/reason  
- tipografia  
- fuse decision monólito  

## Plano W3

1. Judgment face/spoken/pack.  
2. Wire ReasonSheet.  
3. CODEMAP.  
4. ~5 files · ~200–350 LOC.

## Proof

1. Empty actor → blocked face.  
2. Optional reason + actor → ready.  
3. Required reason empty → blocked.  
4. Spoken confirm includes title.  
5. DEVICE_PENDING.

## Council

Residual after hub/list can_do closed.

---

## Faces

| Face | Quando |
|---|---|
| blocked | actor empty OR (reason required and empty) |
| ready | actor non-empty AND (optional reason OR non-empty reason) |

## Critérios de rejeição

Se B só mover strings sem face/canSubmit → fail.

---

*End WAVE-098 design.*
