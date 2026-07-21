# WAVE-042 — execution-proof-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-042-execution-proof-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ExecutionProof` (~525 LOC) owns **shouldDisplay**, decision surface gate,
  summaryLine, spoken metrics, quality/decision copy — **no** pure
  `ExecutionProofJudgment`.
- Collapsed header always says **"Obra concluída"** even when the surface is
  decision-only or quality-only without activities — product word lies.
- Artifact items list is wire-order; post-041 we already have
  `ArtifactJudgment.rankItems` — proof should consume it for evidence order.
- Operator cannot **judge what kind of proof** is present in ≤5s (decision ·
  quality · steps · artifacts) — only a generic completed label.
- Residual after plan (040) + artifacts (041): the **proof organ** that wraps
  finished turns still lacks exclusive face grammar.

## Patamar

| Antes | Depois |
|---|---|
| "Obra concluída" always | Face: decision / quality / steps / evidence / compound |
| shouldDisplay View-static | Judgment.shouldDisplay |
| Decision gate on View | Judgment.hasDecisionSurface |
| Artifact wire order | ArtifactJudgment.rankItems |
| Spoken ad hoc | pack + face spoken |

Δ = **soberania da prova** — saber o que a obra prova ao recolher o card.

---

## Arquitetura

### Princípios

- Casca only; bubble decision/quality/activities + artifacts published.
- Honesty: face reflects **what is published**, never invent quality score.
- One domain: execution proof judgment.
- Reuse ArtifactJudgment for item rank (no duplicate kind grammar).
- Density: Judgment pure · thin face in collapsed header · Proof surface 1 domain.

### Fluxo

```
bubble + artifactItems
  → ExecutionProofJudgment.face / shouldDisplay / summary
  → collapsed header kicker from face
  → expanded sections order honesty (decision → quality → steps → artifacts)
  → ranked artifacts via ArtifactJudgment
```

### Módulos

| Nome | Papel |
|---|---|
| `ExecutionProofJudgment` | face · gates · summary · pack · spoken |
| ExecutionProof | consume Judgment |
| Artifact rank | ArtifactJudgment |
| CODEMAP | proof face |

### Arquivos (≥5)

- `ExecutionProofJudgment.swift` (**new**)
- `ExecutionProof.swift`
- maybe thin face stays in header (no separate strip if header IS face)
- `A11yID.swift` if needed
- `CODEMAP.md`
- evidence design/compress
- optional: ConversationMessages call site if shouldDisplay used

Need ≥5 files: Judgment, Proof, CODEMAP, design, compress, A11y if touch, messages if shouldDisplay moves.

Also check call sites of `ExecutionProof.shouldDisplay` / `hasDecisionSurface`.

### Densidade

Judgment 200–800 · Proof shrinks dialect · no multi-domain.

### Fora de escopo

- Core  
- LiveTimeline re-rank (chrono sacred)  
- Micro tipografia  
- Arena  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive proof face product words + spoken (not always "obra concluída").
2. `shouldDisplay` + `hasDecisionSurface` owned by Judgment.
3. Collapsed kicker/summary from Judgment.
4. Artifacts in proof ranked via ArtifactJudgment.
5. Pack facts for decision/quality/steps/artifacts.
6. Spoken collapsed uses face.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent decision  
- re-order chrono live timeline  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire ExecutionProof  
3. Rank artifacts  
4. CODEMAP  
5. compress · DONE · regen  

Estimativa: **5–7 files · 280–400 LOC**.

## Proof

1. Decision-only bubble → face decision, not generic completed.  
2. Quality + steps → compound face.  
3. Artifacts image before file in proof list.  
4. shouldDisplay false when empty.  
5. DEVICE_PENDING.

## Council

Post-041 empty queue. Proof organ residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-042 design.*
