# WAVE-052 — execution-state-card-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-052-execution-state-card-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ExecutionStateCard` (~678 LOC) repeats **switch state.kind** for icon,
  badge, spoken, tint, timer freeze — parallel dialect soup **not** in a
  pure Judgment module.
- Phase face (022/023/027) owns strip/presence; **StateCard chrome** still
  invents local product words (PAUSADO / AGUARDANDO / RECONECTANDO) without
  shared grammar reusable by a11y pack hosts.
- Agent-optimal residual: extract Judgment so 1 read = full kind chrome;
  ↓LOC by intention on the card.
- Operator-facing: one product language for attention kinds on the card.

## Patamar

| Antes | Depois |
|---|---|
| 6+ switch kind sites | Judgment pure maps |
| Badge/spoken/tint drift | One map per kind |
| Card dense dialect | Thinner card · Judgment 200–500 |

Δ = **soberania do StateCard** — kind → chrome sem sopa.

---

## Arquitetura

### Princípios

- Casca only; `AtlasExecutionPresentationState.Kind` already.
- Align spoken with phase attention words where already published
  (ConversationExecutionPhase) — do not invent new attention kinds.
- One domain: execution state card chrome.

### Fluxo

```
state.kind
  → ExecutionStateCardJudgment.icon / badge / spoken / tint / freezesTimer
  → ExecutionStateCard peels call Judgment only
```

### Arquivos (≥5)

- `ExecutionStateCardJudgment.swift` (**new**)
- `ExecutionStateCard.swift` wire
- CODEMAP
- design + compress
- optional ConversationExecutionPhase cross-ref only if needed

### Densidade

Judgment 150–400 · Card shrinks dialect.

### Fora de escopo

- Core presentation DTO  
- Reopen strip 031  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Judgment owns icon/badge/spoken/tint/freezesTimer for all Kind cases.
2. Card peels call Judgment — no parallel switch soup for those maps.
3. Spoken product words stable for a11y.
4. freezesTimer only for attentionRequired/awaitingExternal.
5. Gates + CODEMAP.
6. DEVICE_PENDING.
7. LOC card dialect ↓ (net judgment extract).

## Anti-objetivos

- invent kinds  
- fuse card into strip monólito  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire card  
3. CODEMAP · compress  

Estimativa: **5–6 files · 250–400 LOC**.

## Proof

1. attentionRequired → PAUSADO + shield + freeze timer.  
2. failed → xmark + spoken fail.  
3. completed → seal.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Dense residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-052 design.*
