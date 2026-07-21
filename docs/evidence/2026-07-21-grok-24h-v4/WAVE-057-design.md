# WAVE-057 — codigo-provenance-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-057-codigo-provenance-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeProvenanceSheet` + sections (~573 LOC combined a11y/phase)
  switch `phase` for loading/failed/loaded-empty/loaded-body without a
  pure **Judgment** face.
- State kicker (onMain/healed/violating/history) duplicates commit-row
  dialect without shared product words for pack hosts.
- Loaded empty (“ledger sem detalhe”) vs failed are easy to confuse
  without exclusive faces.
- Residual after Why biography (056) and commit-row face (054): the
  **provenance drill** organ still View-owned soup.

## Patamar

| Antes | Depois |
|---|---|
| phase switch soup | Exclusive provenance face |
| State kicker local | Align product words with row/graph |
| Spoken local | Judgment spoken sheet |
| No pack | Pack phase + files + agent |

Δ = **soberania da proveniência** — fail ≠ empty ledger ≠ loaded body.

---

## Arquitetura

### Princípios

- Casca only; phase + `AtlasCodeProvenance` already published.
- Honesty: empty body is not failure; failed uses published message.
- State kicker reuses commit-row / graph product vocabulary.
- One domain: código provenance sheet.

### Fluxo

```
phase + node state + provenance?
  → AtlasCodeProvenanceJudgment.face / spoken / pack
  → ProvenanceSheet peels
```

### Arquivos (≥5)

- `AtlasCodeProvenanceJudgment.swift` (**new**)
- `AtlasCodeProvenanceSheet.swift`
- `AtlasCodeProvenanceSections.swift` (if spoken shared)
- CODEMAP
- design + compress

### Densidade

Judgment 150–400 · Sheet ↓ dialect.

### Fora de escopo

- Core provenance API  
- Why sheet rewrite (056)  
- Spine rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: loading · failed · empty · body(files).
2. Spoken sheet from Judgment (header + state + phase).
3. contentPhaseID from face.
4. hasLoadedBody pure Judgment.
5. Pack facts face + file count + agent absence.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent files  
- fuse with Why monólito  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire sheet  
3. CODEMAP · compress · DONE · regen  

Estimativa: **5–7 files · 250–400 LOC**.

## Proof

1. Loading → face loading.  
2. Fail message → failed face.  
3. Loaded no body → empty face.  
4. Loaded with files → body face.  
5. DEVICE_PENDING.

## Council

Empty QUEUE after 056. Provenance residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-057 design.*
