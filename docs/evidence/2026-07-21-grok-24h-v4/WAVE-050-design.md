# WAVE-050 — arena-live-control-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-050-arena-live-control-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A runner-up arena-live-control)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArenaPremiumExecutionView.orderedRuns` is ad hoc filter soup:
  live → done → queued — **failed** sits inside done without attention
  elevation; no pure Judgment.
- Stop CTA / primary run / status label dialects live in views without
  exclusive **live control face** (idle · running · stopping · attention).
- Residual named in A 047 council: `arena-live-control-judgment`.
- Operator judging multi-run measurement cannot see **failed** before
  completed in the corridas list.

## Patamar

| Antes | Depois |
|---|---|
| Filter soup order | Pure rank: live → failed → done → queued |
| No face | Face exclusive + pack |
| Stop law local | Judgment canStop helper |
| Status tones View | Shared product words |

Δ = **soberania da medição ao vivo** — falha sobe, stop honesto.

---

## Arquitetura

### Princípios

- Casca only; `AtlasArenaLiveRun` already published.
- Honesty: empty runs → idle/empty face.
- Failed elevates after live, before quiet completed.
- One domain: Arena live control.

### Fluxo

```
runs + primary
  → ArenaLiveControlJudgment.rank / face / canStop / pack
  → ExecutionView orderedRuns = rank
  → optional Now/Running consume face words
```

### Arquivos (≥5)

- `ArenaLiveControlJudgment.swift` (**new**)
- `ArenaPremiumExecutionView.swift`
- optional RunningView / NowView
- CODEMAP
- design + compress
- A11y if needed

### Densidade

Judgment 150–400.

### Fora de escopo

- Core stop API  
- Regression badge on Home  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Rank pure: running/stopping → failed → completed/stopped → queued → unknown.
2. Face: empty · running · stopping · attention(failed) · quietDone · queued.
3. Execution list uses Judgment.rank only.
4. canStop honesty from published canStop + measurement id.
5. Pack facts top runs + face.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent failed  
- Home regression  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire ExecutionView  
3. CODEMAP · compress  

Estimativa: **5–7 files · 220–380 LOC**.

## Proof

1. Failed + completed → failed first after live.  
2. Running primary → face running.  
3. canStop false when nil measurement.  
4. DEVICE_PENDING.

## Council

A 047 runner-up #4. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-050 design.*
