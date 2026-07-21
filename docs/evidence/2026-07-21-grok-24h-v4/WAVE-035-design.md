# WAVE-035 — autonomos-transfer-handoff-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-035-autonomos-transfer-handoff-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Pack invite already suggests **"devo transferir?"** on incident, but
  **zero UI call sites** for `model.transfer` / `refreshTransferStatus`
  (`rg model.transfer` App = model only).
- Core + Model ready: `transferAutonomosMission`, handoff status polling,
  `lastTransferReceipt` with honesty flags
  (`isAwaitingSourceRelease`, `isTargetClaimed`).
- After WAVE-030 (loop control) and WAVE-033 (revert veto), residual
  **mission handoff** is the remaining steward action: operator moves the
  same `area+focus` mission to another worker with audit trail.
- Hub has control CTAs but **no transfer path** — operator cannot enact
  the pack suggestion.

## Patamar

| Antes | Depois |
|---|---|
| transfer only in model | Hub CTA when canControl → ReasonSheet → transfer |
| lastTransferReceipt dead | Receipt line + refresh status honesty |
| Pack "devo transferir?" empty | Pack facts handoff status / absences |
| Zero steward handoff | Operator **requests transfer with receipt** |

Δ = soberania de **handoff de missão** — fila escolhe target; casca não
mente start.

---

## Arquitetura

### Princípios

- Casca only; existing model.transfer / lastTransferReceipt.
- Honesty: unbound/unregistered → no transfer theater.
- Transfer does **not** start target — receipt shows awaiting/claimed.
- Reuse ReasonSheet (actor + reason required).
- Judgment pure for canTransfer + receipt spoken line.

### Fluxo

```
Hub (area canControl)
  → nav "Transferir missão"
  → ReasonSheet
  → model.transfer(actor, reason)
  → lastTransferReceipt line
  → optional refreshTransferStatus
```

### Módulos

| Nome | Papel |
|---|---|
| `AutonomosTransferJudgment` | canTransfer · receiptLine · face words |
| Hub + MapShell | wire CTA + sheet |
| Pack | handoff facts |

### Arquivos

- `AutonomosTransferJudgment.swift` (**new**)
- `AutonomosHubView.swift` — transfer nav when allowed
- `AutonomosMapShell.swift` — ReasonSheet transfer path
- `AutonomosAskContext.swift` — pack facts
- CODEMAP

### Densidade

Judgment 200–800 · hub thin · no monólito

### Fora de escopo

- Worker picker invent (server chooses target)  
- Core new fields  
- Continuity  
- Full transfer cockpit multi-screen  
- Evolution rewrite (034 done)

### §5

`nenhum`.

---

## DoD (≥5)

- [ ] Hub shows Transfer when canControlSelectedArea.
- [ ] CTA → ReasonSheet → model.transfer.
- [ ] Receipt line from lastTransferReceipt (awaiting/claimed honesty).
- [ ] No transfer theater when unbound/unregistered.
- [ ] Pack includes handoff facts/absences when receipt exists.
- [ ] controlError on failure.
- [ ] Gates + CODEMAP transfer handoff.

## Anti-objetivos

- invent target host  
- micro tipografia  
- Core  
- multi-domínio fuse  
- micro-WAVE

## Plano W3

1. Judgment  
2. Hub + MapShell wire  
3. Pack  
4. CODEMAP  
5. ~5–7 files · 200–400 LOC

## Proof / device

1. Bound registered area → Transfer nav.  
2. Submit → receipt awaiting honesty.  
3. Unbound → no CTA.  
4. DEVICE_PENDING.

## Council

Transfer was deferred from 030 scope. Residual high steward action.

## §WAVE self-check

1. Patamar sim  
2. DoD≥5 sim  
3. Casca sim  
4. Design≥120 sim  
5. ≥5 files sim  
6. Densidade sim  
