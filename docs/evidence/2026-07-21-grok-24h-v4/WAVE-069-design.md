# WAVE-069 — editorial-turn-signature-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-069-editorial-turn-signature-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual EditorialTurn A11y)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `EditorialTurnA11y` owns signature who/duration + feedback spoken
  **without pure Judgment** for the editorial turn organ.
- Present vs absent signature and feedback active states are View-local;
  pack cannot reuse `editorial_signature_face: present|absent` or
  feedback product words cleanly.
- Residual after proof/plan/artifact judgments: **assinatura + feedback
  do turno** still dialect soup.

## Patamar

| Antes | Depois |
|---|---|
| A11y helpers only | Exclusive signature face |
| Feedback base local | Judgment feedback spoken |
| No pack | Pack signature + feedback |

Δ = **soberania da assinatura editorial** — quem respondeu, com honestidade.

---

## Arquitetura

### Princípios

- Casca only; provider/model/elapsedMs published on bubble.
- Honesty: no invent who; empty model/_default silenced (existing law).
- One domain: editorial signature + feedback grammar.

### Fluxo

```
provider + model + elapsedMs + feedback?
  → EditorialTurnJudgment.face / spoken / feedback / pack
  → EditorialTurn A11y peels
```

### Arquivos (≥5)

- `EditorialTurnJudgment.swift` (**new**)
- `EditorialTurn.swift`
- CODEMAP
- design + compress

### Densidade

Judgment 140–260.

### Fora de escopo

- Core routing  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Signature face: present · absent.
2. spokenSignature from Judgment.
3. Feedback spoken base/active from Judgment.
4. Pack face + who? + duration?
5. Wire A11y peels.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent provider  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire A11y  
3. CODEMAP · compress  

Estimativa: **5 files · 200–320 LOC**.

## Proof

1. model present → present face.  
2. empty → absent.  
3. feedback active spoken.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Editorial residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-069 design.*
