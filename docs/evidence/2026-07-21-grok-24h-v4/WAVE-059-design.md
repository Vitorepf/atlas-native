# WAVE-059 — arena-suite-engines-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-059-arena-suite-engines-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArenaSuiteSheet` lists `suite.engines` in **wire order** — regressed
  engines can sit under quiet engines; operator cannot judge **who regressed**
  in ≤5s.
- Suite kicker uses `hasRegression` but engines lack pure **rank/face**
  Judgment (only A11y spoken soup).
- Residual after Arena score (existing) + live control (050) + start (055):
  **suite drill organ** still View-owned list dialect.

## Patamar

| Antes | Depois |
|---|---|
| Wire-order engines | Rank: regressed → measured → unmeasured |
| Kicker only | Face + ranked engines + pack |
| Spoken only | Judgment spoken engine/suite |

Δ = **soberania do drill de suíte** — regressão sobe primeiro.

---

## Arquitetura

### Princípios

- Casca only; `regressed` + scores already published.
- Honesty: nil score = unmeasured (not invent 0).
- Align with ArenaScoreJudgment vocabulary where possible.
- One domain: Arena suite sheet.

### Fluxo

```
suite.engines
  → ArenaSuiteJudgment.rank / face / spoken
  → SuiteSheet ForEach ranked
```

### Arquivos (≥5)

- `ArenaSuiteJudgment.swift` (**new**)
- `ArenaSuiteSheet.swift`
- CODEMAP
- design + compress
- optional A11y consolidate

### Densidade

Judgment 150–400.

### Fora de escopo

- Core scoreboard  
- Home regression badge  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Rank: regressed first, then measured score desc, wire-stable.
2. Exclusive suite face: empty · quiet · regression(N).
3. Sheet ForEach uses ranked engines only.
4. Spoken suite/engine from Judgment.
5. Pack top engines + face.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent scores  
- Home regression  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire SuiteSheet  
3. CODEMAP · compress  

Estimativa: **5–6 files · 220–360 LOC**.

## Proof

1. Suite with mixed regressed → regressed engines first.  
2. Face regression(N).  
3. Quiet suite → quiet face.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Suite residual after score/live/start instruments.  
Operator opens suite drill to judge which motor regressed — wire order
hides that. §WAVE pass.

## §WAVE self-check

1–6 yes.

## Notas de implementação

- Rank secondary key = higher score among measured (operator sees best
  quiet motors after attention).
- Unmeasured (nil score) after measured; never invent 0.0 score.

---

*End WAVE-059 design.*
