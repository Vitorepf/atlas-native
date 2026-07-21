# WAVE-076 — composer-effort-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-076-composer-effort-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after WAVE-046 send)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ComposerToolbar` owns effort spoken labels (auto/fast/balanced/deep/max)
  and options/input processing chrome **without pure Judgment** for the
  effort organ.
- WAVE-046 closed send readiness; residual **effort picker + options
  menu grammar** still View-local dialect soup.
- Pack hosts cannot reuse `composer_effort_face: auto|fast|balanced|
  deep|max` alongside send face.

## Patamar

| Antes | Depois |
|---|---|
| Switch soup effort spoken | Exclusive effort face |
| Options/input spoken local | Judgment spoken |
| No pack effort | Pack effort + shortLabel honesty |

Δ = **soberania do esforço do próximo envio** — o operador escolhe o
nível com uma língua.

---

## Arquitetura

### Princípios

- Casca only; `AtlasComputeEffort` + model.effort published.
- Honesty: never invent effort; map only published enum cases.
- One domain: composer effort/options chrome (not send readiness).

### Fluxo

```
effort + bubbles empty? + isExecuting?
  → ComposerEffortJudgment.face / spoken / pack
  → ComposerToolbar peels
```

### Arquivos (≥5)

- `ComposerEffortJudgment.swift` (**new**)
- `ComposerToolbarChrome.swift`
- CODEMAP
- design + compress
- optional ComposerQueue if effort pack shared

### Densidade

Judgment 140–280.

### Fora de escopo

- Core compute routing  
- Send readiness rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: auto · fast · balanced · deep · max.
2. spokenEffortLabel/Hint from Judgment.
3. spokenInput / processing / optionsHint from Judgment.
4. Pack effort face + product words.
5. accessibilityValue on effort control = productWord.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent effort levels  
- fuse with SendJudgment file  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Toolbar chrome  
3. CODEMAP · compress  

Estimativa: **5–6 files · 200–340 LOC**.

## Proof

1. effort .fast → face fast spoken.  
2. empty bubbles → input spoken “mensagem para o Atlas”.  
3. max → effort máximo.  
4. DEVICE_PENDING.

## Council

Empty QUEUE after idle FilterChrome. Effort residual after send. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-076 design.*
