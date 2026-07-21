# WAVE-060 — conversation-stale-read-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-060-conversation-stale-read-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `StaleReadSeal` / `StaleReadSealA11y` own caption + spoken for cache age
  and sync confirmation **without pure Judgment**.
- Confirming vs aged-read faces are View-local; pack hosts cannot reuse
  `stale_read_face: confirming|aged`.
- Age display uses `atlasRelativeAgePT` correctly but product face for
  **staleness severity** (fresh / aged / confirming) is missing.
- Residual after queue/send/steer instruments: **cache honesty seal** on
  conversation surface still dialect soup in ChromeExtras.

## Patamar

| Antes | Depois |
|---|---|
| Caption local | Judgment face + caption |
| Spoken local | Judgment spoken |
| No pack | Pack age_s + face |
| No severity | fresh / aged / confirming |

Δ = **soberania da leitura em cache** — saber se o fio está fresco ou envelhecido.

---

## Arquitetura

### Princípios

- Casca only; `capturedAt` + confirming already.
- Honesty: age from published capture time only.
- One domain: conversation stale-read seal.

### Fluxo

```
capturedAt + now + confirming
  → ConversationStaleReadJudgment.face / caption / spoken / pack
  → StaleReadSeal peels
```

### Arquivos (≥5)

- `ConversationStaleReadJudgment.swift` (**new**)
- `ConversationChromeExtras.swift`
- CODEMAP
- design + compress
- optional ConversationSurface (no logic change)

### Densidade

Judgment 150–300.

### Fora de escopo

- Core cache  
- App Group  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: confirming · fresh · aged · stale (age buckets).
2. Caption + spoken from Judgment.
3. Age buckets published thresholds only (honest relative age).
4. Pack age_seconds + face.
5. reduceMotion caption path preserved.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent capture time  
- Continuity App Group  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire seal a11y  
3. CODEMAP · compress  

Estimativa: **5–6 files · 200–320 LOC**.

## Proof

1. confirming → face confirming.  
2. recent capture → fresh.  
3. old capture → aged/stale caption.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Cache seal residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

## Notas

- Thresholds: fresh < 5m, aged < 1h, stale ≥ 1h (display only; copy still
  uses relative age string for honesty).

---

*End WAVE-060 design.*
