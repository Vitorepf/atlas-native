# WAVE-056 — codigo-why-biography-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-056-codigo-why-biography-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeWhySheet` (~233 LOC) switches `model.phase` for loading /
  failed / loaded empty / timeline + truncated banner — **no pure
  Judgment** face for biography organ.
- Spoken labels and phase IDs are View-local; pack hosts cannot reuse
  `why_face: truncated|empty|failed|timeline`.
- Fail vs empty (honest absence of commits) are easy to confuse without
  exclusive product words.
- Residual after commit-row (054) and graph judgment: **file biography
  (H1 Why)** still View dialect.

## Patamar

| Antes | Depois |
|---|---|
| phase switch soup | Exclusive why face |
| Spoken local | Judgment spoken |
| Truncation banner only | Face truncated with counts |
| No pack | Pack commits/truncated/fail |

Δ = **soberania da biografia** — empty ≠ fail ≠ truncado.

---

## Arquitetura

### Princípios

- Casca only; `AtlasCodeWhy` + model phase/message already.
- Honesty: failed uses published message; empty commits ≠ invent history.
- One domain: código why biography.

### Fluxo

```
model.phase + why + message
  → AtlasCodeWhyJudgment.face / spoken / pack
  → WhySheet peels
```

### Arquivos (≥5)

- `AtlasCodeWhyJudgment.swift` (**new**)
- `AtlasCodeWhySheet.swift`
- CODEMAP
- design + compress
- optional AskContext pack hook if why open

### Densidade

Judgment 150–350 · Sheet thin.

### Fora de escopo

- Core why API  
- Graph rank  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: loading · failed · empty · timeline · truncated.
2. Spoken sheet/header from Judgment.
3. Truncated uses published commits.count / commitsTotal only.
4. Failed includes message when published.
5. Pack facts face + counts + absences.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent commits  
- fuse with provenance sheet  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire WhySheet  
3. CODEMAP · compress  

Estimativa: **5–6 files · 220–350 LOC**.

## Proof

1. Loading → face loading.  
2. Empty commits → empty not failed.  
3. Truncated banner + face truncated.  
4. Fail with message → failed face.  
5. DEVICE_PENDING.

## Council

Empty QUEUE. Why residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-056 design.*
