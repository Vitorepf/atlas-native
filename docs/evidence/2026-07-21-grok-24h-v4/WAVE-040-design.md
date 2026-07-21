# WAVE-040 — plan-execution-progress-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-040-plan-execution-progress-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `PlanCard` (~854 LOC) owns **step state**, progress badge, audit terminal,
  spoken, and chip packing — **zero** pure `PlanJudgment` module.
- Progress is raw `current/total` badge + step dots; no exclusive **plan face**
  grammar (pending / running / terminal / absent) shared with cockpit strip.
- Cockpit (`ConversationCockpitBody`) duplicates progress line as
  `"\(p.current)/\(p.total) · \(p.title)"` — second dialect of the same fact.
- TurnPresence also peeks `executionProgress` without shared grammar.
- Operator cannot **judge plan progress in ≤5s** with one product word +
  current step honesty; audit terminal only appears when audit mode +
  terminal (good) but face is not first-class.
- Residual after conversation phase/decision WAVEs (022–031) and change-review
  risk (039): **plan organ** still View-owned dialect soup.

## Patamar

| Antes | Depois |
|---|---|
| stepState no View | Judgment pure |
| Badge numérico só | Plan face exclusive |
| Cockpit string local | same Judgment summary |
| Spoken ad hoc | pack + spoken face |
| PlanCard monólito | Judgment + thin face strip |

Δ = **soberania do plano vivo** — um face para card e strip.

---

## Arquitetura

### Princípios

- Casca only; `AtlasExecutionPlan` + `Progress` already on bubble.
- Honesty: nil progress → pending/absent face (never invent checkpoint).
- Terminal only from published `isTerminal`.
- stepState(idx, progress, stepCount) pure — View calls Judgment.
- One domain: plan progress judgment — not change-review, not Autônomos.
- Density: Judgment 200–800; strip thin; PlanCard shrinks intent.

### Fluxo

```
bubble.executionPlan + executionProgress
  → PlanJudgment.face / stepState / summary / pack
  → PlanFaceStrip on PlanCard (under header)
  → PlanCard steps use Judgment.stepState
  → Cockpit strip meta uses Judgment.summaryLine
  → spoken card + a11y plan-face
```

### Módulos

| Nome | Papel |
|---|---|
| `PlanJudgment` | face · stepState · summary · pack · spoken |
| `PlanFaceStrip` | thin exclusive face chrome |
| `PlanCard` | consume Judgment |
| Cockpit strip | shared summary |
| CODEMAP | onde muda plan face |

### Arquivos (≥5)

- `PlanJudgment.swift` (**new**)
- `PlanFaceStrip.swift` (**new**)
- `PlanCard.swift` — wire step + face + spoken
- `ConversationCockpitBody.swift` — strip summary
- `A11yID.swift` — planFace
- `CODEMAP.md`
- evidence design/compress

### Densidade

Judgment 200–800 · Strip thin · PlanCard still 1 domain · no route shell.

### Fora de escopo

- Core new progress DTO  
- Revision compare rewrite (keep)  
- Micro tipografia  
- Autônomos / Arena / Continuity  
- Invent checkpoint when nil  

### §5

`nenhum` — plan/progress already provider-safe.

---

## DoD (≥5)

1. Exclusive **plan face**: absent · pending (plan, no progress) · running ·
   terminal — product words + spoken.
2. `stepState` pure in Judgment; PlanCard/step row call it only.
3. `PlanFaceStrip` under header when plan present; quiet honesty when
   no plan (card gated already).
4. Summary line: `N/M · title · terminal|curso` shared with cockpit strip.
5. Pack: agents/tools/gates/progress facts + absences if empty.
6. Card spoken label uses Judgment face + summary.
7. Cockpit progress meta uses Judgment (no local dialect string).
8. Gates green + CODEMAP plan face line.
9. DEVICE_PENDING if no device.

## Anti-objetivos

- invent progress  
- fuse PlanCard into ExecutionProof  
- Core  
- micro-WAVE rename-only  
- dogmatic peel storm of revision compare  

## Plano W2 / W3

1. PlanJudgment  
2. PlanFaceStrip  
3. Wire PlanCard stepState + spoken + face  
4. Cockpit summary  
5. A11y + CODEMAP  
6. compress · DONE · regen · LEDGER  

Estimativa: **6–8 files · 300–450 LOC**.

## Proof

1. Plan with progress mid-run → face running + strip N/M · title.  
2. Terminal progress → face terminal; step all done.  
3. Plan without progress → pending face, all steps pending.  
4. Cockpit strip same summary as card.  
5. DEVICE_PENDING.

## Council

Post-039 empty queue. Residual plan organ dialect across PlanCard +
Cockpit. Passes §WAVE.

## §WAVE self-check

1. Patamar sim  
2. DoD≥5 sim  
3. Casca sim  
4. Design≥120 sim  
5. ≥5 files / not micro sim  
6. Densidade sim  

---

*End WAVE-040 design.*
