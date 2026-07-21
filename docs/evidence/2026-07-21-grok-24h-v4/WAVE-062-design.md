# WAVE-062 — codigo-ask-pill-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-062-codigo-ask-pill-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after WAVE-061)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeAskPillA11y` owns invite vs anchoring spoken + phase IDs
  **without pure Judgment**.
- Anchor legend partial vs full vs invite are View-local; pack hosts
  cannot reuse `ask_pill_face: invite|anchoring|legend`.
- Clear-filter chrome copy is co-located dialect; pill organ cannot be
  read in one Judgment file for AI navigation.
- Residual after graph screen (061) and Why/Provenance/Health: **pílula
  de ask no Código** still Surface dialect soup.

## Patamar

| Antes | Depois |
|---|---|
| Bool isAnchoring soup | Exclusive ask pill face |
| Spoken local | Judgment spoken |
| Phase ID string only | Face productWord + phaseID |
| Pack ad-hoc in AskContext | Pack face + legend absence |

Δ = **soberania da pílula** — convidar ≠ recorte ancorado ≠ legenda.

---

## Arquitetura

### Princípios

- Casca only; `isAnchoring` + `anchorLegend` already published.
- Honesty: never invent legend text; empty legend while anchoring is
  honest “grafo recortado” fallback already shipped.
- One domain: código ask pill organ (not graph screen load, not health).

### Fluxo

```
isAnchoring + anchorLegend?
  → AtlasCodeAskPillJudgment.face / spoken / phaseID / pack
  → AtlasCodeSurface askPillA11yTraits peels
```

### Arquivos (≥5)

- `AtlasCodeAskPillJudgment.swift` (**new**)
- `AtlasCodeSurface.swift`
- optional `AtlasCodeAskContext.swift` pack hook
- CODEMAP
- design + compress

### Densidade

Judgment 130–250.

### Fora de escopo

- Core ask API  
- Composer send  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: `invite` · `anchoring` · `legend` (legend when
   anchoring + non-empty legend string).
2. Spoken pill from Judgment.
3. phaseID from Judgment (animation token preserved).
4. Clear control labels stay constants (or Judgment clearLabel/Hint).
5. Pack face + anchoring + legend? + absences.
6. accessibilityValue = face productWord on pill.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent anchor legend  
- fuse with GraphScreenJudgment  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Surface + AskContext pack if cheap  
3. CODEMAP · compress  

Estimativa: **5–6 files · 200–320 LOC**.

## Proof

1. !anchoring → invite.  
2. anchoring + legend → legend face + spoken includes legend.  
3. anchoring + empty legend → anchoring face fallback copy.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Pill residual after 061. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-062 design.*
