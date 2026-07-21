# WAVE-048 — codigo-heal-veto-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-048-codigo-heal-veto-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE · runner-up from A 047 council)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeModel.undoError` is set on failed `undoLastHeal` — **casca never
  renders it** (rg: only write site). Operator taps “Desfazer — com recibo”,
  sheet **dismisses immediately**, failure is silent → **veto lies**.
- Heal receipt sheet owns canUndo / window note / spoken ad hoc — **no**
  pure `AtlasCodeHealVetoJudgment` face (absent · completed · blocked ·
  vetoOpen · vetoClosed · undoFailed).
- Pack canDo knows heal CTA exists but not **veto window open/closed** or
  last undo failure.
- Residual named in A council WAVE-047 runner-ups: `codigo-heal-veto-judgment`.
- Self-construction veto (033) exists for Autônomos cycles; **Código heal
  veto** still incomplete honesty.

## Patamar

| Antes | Depois |
|---|---|
| undoError dark | Error line + spoken on receipt |
| Dismiss before result | Stay open; show face undoFailed |
| canUndo in View | Judgment face |
| Pack silent on veto | Pack veto_face + window + error |
| Operator blind | ≤5s knows can veto / window closed / fail |

Δ = **soberania do veto da cura** — desfazer com recibo não some no vazio.

---

## Arquitetura

### Princípios

- Casca only; `AtlasCodeHealResponse` + `undoError` already published.
- Honesty: nil heal → absent; closed window → vetoClosed (not invent open).
- Do **not** dismiss sheet on undo tap; clear error only on success.
- One domain: código heal veto.
- Reuse `AtlasCodeUndoWindow` for open/note (no invent deadline).

### Fluxo

```
heal + undoError
  → HealVetoJudgment.face / canVeto / spoken / pack
  → ReceiptSheet: face chrome + undoError line
  → onUndo → model.undoLastHeal (no auto-dismiss)
  → success: undoError nil, heal refreshed
  → fail: undoError shown, face undoFailed
```

### Módulos

| Nome | Papel |
|---|---|
| `AtlasCodeHealVetoJudgment` | face · canVeto · pack · spoken |
| `AtlasCodeHealReceiptSheet` | wire error + face |
| Sheets host | pass undoError |
| AskContext | pack veto |
| CODEMAP | heal veto |

### Arquivos (≥5)

- `AtlasCodeHealVetoJudgment.swift` (**new**)
- `AtlasCodeHealReceiptSheet.swift`
- `AtlasCodeSurface.swift` (sheet args)
- `AtlasCodeModel.swift` — clear undoError on success (presentation state)
- `AtlasCodeAskContext.swift` — pack
- `A11yID.swift` — undo error id
- CODEMAP + design/compress

### Densidade

Judgment 200–500 · Sheet stays 1 domain · no multi-domain.

### Fora de escopo

- Core heal API rewrite  
- Self-construction Autônomos veto re-open  
- Micro tipografia  
- Arena  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: absent · completed · blocked · vetoOpen · vetoClosed · undoFailed.
2. `undoError` rendered when present; a11y spoken includes error.
3. Undo button does **not** dismiss before result.
4. Success clears undoError; fail keeps sheet + error.
5. canVeto from Judgment (healId + window open).
6. Pack: veto_face + window + error/absence.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent undo success  
- dismiss-on-tap theater  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Model clear error on success  
3. Sheet wire + no dismiss  
4. Pass undoError from host  
5. Pack + CODEMAP  
6. compress · DONE · regen  

Estimativa: **6–8 files · 280–450 LOC**.

## Proof

1. Undo fail path → error visible on sheet.  
2. Window closed → no button; face vetoClosed.  
3. Window open → button; face vetoOpen.  
4. Success → error gone, heal refreshed.  
5. DEVICE_PENDING.

## Council

Empty QUEUE. A 047 named heal-veto runner-up high. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-048 design.*
