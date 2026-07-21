# WAVE-068 — trace-evidence-chrome-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-068-trace-evidence-chrome-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after TraceEvidence peel)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `TraceEvidenceLoading` / `TraceEvidenceUnavailable` + `TraceEvidenceCopy`
  are shared evidence chrome across ChangeReview / Artifacts with
  **no pure Judgment** for exclusive evidence face.
- Reason mapping is dialect soup; pack hosts cannot reuse
  `trace_evidence_face: loading|unavailable` + known reason product words.
- Residual after preview peels (idle 9) and change-review sheet load
  (063): **evidence organ honesty** still copy-local.

## Patamar

| Antes | Depois |
|---|---|
| Free strings | Exclusive evidence face |
| Reason switch local | Judgment known reasons |
| No pack | Pack face + reason |

Δ = **soberania da evidência de trace** — loading ≠ unavailable honesty.

---

## Arquitetura

### Princípios

- Casca only; reason codes already published by server.
- Honesty: unknown reason → raw underscore→space; never invent run.
- One domain: trace evidence chrome (not change-review risk).

### Fluxo

```
loading | (title, reason?)
  → TraceEvidenceJudgment.face / spoken / reason / pack
  → TraceEvidenceChrome peels
```

### Arquivos (≥5)

- `TraceEvidenceJudgment.swift` (**new**)
- `TraceEvidenceChrome.swift`
- optional ChangeReview/Artifact call sites if copy paths remain
- CODEMAP
- design + compress

### Densidade

Judgment 120–220.

### Fora de escopo

- Core evidence API  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face loading · unavailable.
2. Known reason codes → PT honesty (existing map).
3. spokenUnavailable(prefix, reason) from Judgment.
4. Pack face + reason.
5. Wire chrome peels.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent reasons  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Chrome  
3. CODEMAP · compress  

Estimativa: **5 files · 180–280 LOC**.

## Proof

1. loading spoken.  
2. known reason no_workspace.  
3. unknown reason passthrough.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Evidence residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-068 design.*
