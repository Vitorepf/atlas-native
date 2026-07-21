# WAVE-041 — artifacts-evidence-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-041-artifacts-evidence-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArtifactSheet` (~609 LOC) lists artifacts in **wire order** — a large
  `file` can bury a `diff` or `image` that the operator needs first for
  judgment.
- No pure **`ArtifactJudgment`**: face (absent / empty / ready / delivery-
  pressure), kind rank, pack, spoken sheet.
- Delivery mount checks (controls+tests) are **concat wire order** — fails
  not elevated before passes when proving delivery.
- Spoken sheet is count-only; no face of kinds (N imagens · M diffs).
- Residual after change-review risk (039) and plan progress (040): the
  **evidence artifact organ** still lacks judgment grammar on the same
  conversation evidence surface.

## Patamar

| Antes | Depois |
|---|---|
| Wire-order list | Kind attention rank (image/diff first) |
| No face | Exclusive artifact face strip |
| Delivery checks wire | Fail-first delivery rank |
| Count-only spoken | Face + kind summary spoken |
| View-owned dialect | Judgment pure |

Δ = **soberania de evidência** — ver o que prova a obra em ≤5s.

---

## Arquitetura

### Princípios

- Casca only; `AtlasTraceArtifacts.Item` kinds already published.
- Honesty: unavailable/empty → silence faces; never invent items.
- Kind attention order: image → diff → markdown → text → file
  (visual / delta first for operator judgment).
- Delivery checks: fail-first via same statusFailRank as change-review.
- One domain: artifacts evidence judgment.
- Density: Judgment 200–800 · strip thin · sheet stays 1 domain.

### Fluxo

```
artifactsByTrace[trace]
  → ArtifactJudgment.face / rankItems / summary
  → ArtifactFaceStrip under header
  → list uses ranked items (selection stable by id)
  → deliveryChecks ranked fail-first
  → sheet spoken uses face
```

### Módulos

| Nome | Papel |
|---|---|
| `ArtifactJudgment` | kindRank · rank · face · pack · spoken |
| `ArtifactFaceStrip` | thin face chrome |
| ArtifactSheet | wire rank + face + spoken |
| DeliveryProof | fail-first order |
| CODEMAP | artifacts judgment |

### Arquivos (≥5)

- `ArtifactJudgment.swift` (**new**)
- `ArtifactFaceStrip.swift` (**new**)
- `ArtifactSheet.swift`
- `A11yID.swift`
- `CODEMAP.md`
- evidence design/compress

### Densidade

Judgment 200–800 · Strip thin · no multi-domain · no Core.

### Fora de escopo

- Core new artifact fields  
- Preview engine rewrite  
- Micro tipografia  
- Arena / Autônomos  
- Invent kinds  

### §5

`nenhum`.

---

## DoD (≥5)

1. Items ranked by kind attention then wire-stable index.
2. Exclusive face: absent · empty · ready(counts) · with optional delivery fail pressure.
3. `ArtifactFaceStrip` under header when available.
4. Delivery checks fail-first.
5. Sheet spoken includes face/kind summary.
6. Pack facts for kinds + sizes top-N.
7. Selection remains by id after re-rank (first ranked default).
8. Gates + CODEMAP.
9. DEVICE_PENDING.

## Anti-objetivos

- invent artifacts  
- fuse ArtifactViewer into Judgment  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. FaceStrip  
3. Wire sheet list/delivery/spoken  
4. A11y + CODEMAP  
5. compress · DONE · regen  

Estimativa: **6–8 files · 280–420 LOC**.

## Proof

1. Mixed kinds → image/diff above file.  
2. Delivery fail above pass in mount.  
3. Face strip kind counts.  
4. Empty available → empty face honesty.  
5. DEVICE_PENDING.

## Council

Post-040 empty queue. Evidence organ residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-041 design.*
