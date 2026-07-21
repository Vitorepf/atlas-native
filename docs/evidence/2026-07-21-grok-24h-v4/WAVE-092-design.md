# WAVE-092 — artifact-list-row-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-092-artifact-list-row-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia · residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-041 owns **sheet/evidence face** (absent/unavailable/empty/ready/
  deliveryPressure) + rank + pack.
  O **órgão editorial da lista** (list caption · row spoken · empty
  visualizable · close labels · row select hint) ainda é dialeto em
  `ArtifactSheet` strings soltas.
- Preview pane already WAVE-058 `ArtifactPreviewJudgment`.
- Residual: first paint of the list/rows after sheet face is ready.

## Patamar

| Antes | Depois |
|---|---|
| List a11y string soup | **ArtifactListJudgment** faces |
| Row name/size/kind local | spokenRow honesty |
| Empty visualizable local | Judgment empty label |
| Close chrome local | Judgment close |

Δ = **soberania da lista de artefatos** — captions/rows falam a face.

---

## Arquitetura

### Princípios

- Casca only. Items already published on trace artifacts.
- WAVE-041 pétreo: evidence face stays; this is list/row **inside** ready.
- WAVE-058 preview pane stays; don't re-open preview load states.
- Rank stays ArtifactJudgment.rankItems (re-export ok).
- Zero Core.

### Fluxo

```
items[] + selectedID?
  → ArtifactListJudgment
       listFace silence | list(n)
       spokenList · spokenRow · emptyVisualizable
       close labels · select hints
  → ArtifactSheet wire
  → pack artifact_list_face
```

### Tipos

| Nome | Papel |
|---|---|
| `ArtifactListJudgment` | list face · row · empty · close · pack |
| ArtifactSheet | wire |
| ArtifactJudgment | rank re-export; evidence face untouched |
| CODEMAP | |

### Arquivos

- `ArtifactListJudgment.swift` (**new**)
- `ArtifactSheet.swift`
- CODEMAP
- design/compress
- DONE/LEDGER

### Densidade

Judgment 120–280 · Sheet thinner

### Fora de escopo

- Core artifact API  
- Preview load machine (058)  
- Delivery mount animation rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] listFace silence | list(N) product words + spoken.
- [ ] spokenRow(name, size, kind, selected) from Judgment.
- [ ] emptyVisualizable spoken/copy from Judgment.
- [ ] closeLabel/closeHint from Judgment.
- [ ] Pack artifact_list_face + count.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar items  
- fundir preview monólito  
- tipografia  

## Plano W3

1. Judgment list/row/empty/close.  
2. Wire ArtifactSheet.  
3. Pack.  
4. CODEMAP.  
5. ~5 files · ~200–350 LOC.

## Proof

1. Ready with N items → list face list(N).  
2. Select row → selected hint.  
3. Empty visualizable branch spoken.  
4. DEVICE_PENDING.

## Council

Residual after toolbar-091 + sheet-041. Next: ChangeReview run actions (idle/residual).

---

## List faces

| Face | Quando |
|---|---|
| silence | zero items in list chrome |
| list(N) | N ranked visualizable items |

Row: name · byteLabel · kindLabel · selected trait.

## Critérios de rejeição

Se B só renomear strings sem face/pack → fail.  
Se reabrir 041 evidence face product words → fail.

---

*End WAVE-092 design.*
