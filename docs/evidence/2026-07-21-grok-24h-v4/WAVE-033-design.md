# WAVE-033 — self-construction-retroactive-veto-instrument

**Status:** design · proposed  
**Wave:** `WAVE-033-self-construction-retroactive-veto-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- OBRA human role: Intenção · Julgamento · Assinatura · **Veto retroativo com
  recibo**. WAVE-026/030 fecharam assinatura e veto **do loop ao vivo**.
- Residual: **veto do ciclo já entregue** (self-construction merge-proved).
- Wire vivo: `AutonomosModel.revertCycle` + `client.revertAutonomosCycle`.
- UI morta: `SelfConstructionReceiptSheet` tem `canRevert` default **false**
  e `onRevert` no-op; MapShell abre
  `SelfConstructionReceiptSheet(receipt:)` **sem** ligar o path.
- Banner "na fila · ainda não desfeito" só se `revertReceipt != nil` —
  nunca alimentado.
- Operador vê “O Atlas melhorou o próprio app” / merge comprovado e **não
  consegue** o veto com recibo que a constituição promete.

## Patamar

| Antes | Depois |
|---|---|
| Recibo só leitura | Merge-proved + area controlável → **veto fields** |
| canRevert always false | Judgment: merge proof ∧ selectedArea registered |
| onRevert no-op | `model.revertCycle(cycle, actor, reason)` |
| lastRevertReceipt unused in sheet | Bind receipt → queue banner honesty |
| Constituição mente | Operador **veto com recibo** em ≤30s |

Δ = soberania de **veto retroativo** — fecha o quarto pilar humano na casca.

---

## Arquitetura

### Princípios

- Casca only; existing model.revertCycle / lastRevertReceipt / delivered.
- Honesty: no merge proof → no veto theater; unbound area → absence.
- Cycle key: cycleIndex string (route path) — never invent cycleId DTO.
- ReasonSheet grammar already in sheet fields; reuse.
- Pack Autônomos: optional absence if veto not available.

### Fluxo

```
banner merge-proved receipt
  → sheet(item: receipt)
  → Judgment.canRevert(receipt, canControl)
  → if true: veto fields → onRevert → model.revertCycle
  → lastRevertReceipt → banner "na fila"
```

### Módulos

| Nome | Papel |
|---|---|
| `SelfConstructionVetoJudgment` | canRevert · cycleKey · spoken product words |
| Existing sheet/body | already has veto UI |
| MapShell | wire canRevert / onRevert / revertReceipt |

### Arquivos

- `SelfConstructionVetoJudgment.swift` (**new**)
- `AutonomosMapShell.swift` — sheet bind
- `SelfConstructionReceipt*.swift` — only if presentation honesty gaps
- `AutonomosAskContext` — optional absence/fact
- CODEMAP

### Densidade

Judgment 200–800 · shell thin · no god merge Autônomos+Home

### Fora de escopo

- Core new cycleId field if missing from Cycle (use cycleIndex)  
- Continuity App Group  
- Evolution full surface  
- NL mandar-fazer  
- Arena

### §5

`nenhum` se cycleIndex path suffices. Absence if server needs cycleId
and only index is published — still attempt index; error honesty via
controlError.

---

## DoD (≥5)

- [ ] Merge-proved receipt + canControl → canRevert true in sheet.
- [ ] Veto submit calls model.revertCycle with actor/reason.
- [ ] lastRevertReceipt surfaces in sheet banner.
- [ ] No merge / unbound → canRevert false (silence theater).
- [ ] controlError visible if revert fails.
- [ ] Spoken a11y veto path unchanged (already).
- [ ] Gates + CODEMAP “veto retroativo self-construction”.

## Anti-objetivos

- micro tipografia  
- invent merge proof  
- Core invent  
- multi-domínio fuse  
- micro-WAVE

## Plano W3

1. Extract Judgment  
2. Wire MapShell  
3. Error line if needed  
4. Pack absence honesty  
5. CODEMAP  
6. ~5–7 files · 200–400 LOC

## Proof / device

1. Delivered merge-proved + area bound → sheet shows veto.  
2. Submit → receipt queue banner.  
3. No merge → no veto fields.  
4. DEVICE_PENDING.

## Council

Runner-up WAVE-030: self-construction `revertCycle` veto. Δ high —  
fecha constituição “veto com recibo” sem Core.

## §WAVE self-check

1. Patamar: sim  
2. DoD≥5: sim  
3. Casca: sim  
4. Design≥120: sim  
5. ≥5 files / ≥30 min: sim  
6. Densidade: sim  
