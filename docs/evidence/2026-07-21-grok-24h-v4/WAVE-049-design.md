# WAVE-049 — conversation-agent-lanes-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-049-conversation-agent-lanes-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A runner-up agent-lanes)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ExecutionRibbon` renders `bubble.agents` in **wire order** — a failed
  lane can sit under quiet succeeded lanes; operator cannot **judge who
  needs attention** in multi-agent runs.
- `AgentRow` owns status color/word with no pure **lanes Judgment**
  (rank · face · pack · spoken).
- Multi-agent face exists on phase grammar (022/027) but **lanes list**
  is not attention-ranked.
- Residual named in A 047 council: `conversation-agent-lanes-judgment`.

## Patamar

| Antes | Depois |
|---|---|
| Wire-order lanes | Attention rank: failed → awaiting → processing → done |
| No lanes face | Face: empty / single / multi / attention |
| Spoken only phase | Lanes spoken + pack |
| Color on View | Judgment status rank shared |

Δ = **soberania das lanes** — quem falhou sobe primeiro.

---

## Arquitetura

### Princípios

- Casca only; `ExecAgent` on bubble already.
- Honesty: unknown status lowest attention after done, wire-stable.
- Do not invent agent identities.
- One domain: conversation agent lanes.

### Fluxo

```
bubble.agents
  → ConversationAgentLanesJudgment.rank / face / pack
  → ExecutionRibbon ForEach ranked
  → AgentRow optional consume rank helpers
```

### Arquivos (≥5)

- `ConversationAgentLanesJudgment.swift` (**new**)
- `ExecutionRibbon.swift`
- `ConversationCockpitBody.swift` (AgentRow if needed)
- CODEMAP
- design + compress
- A11y if lanes face id

### Densidade

Judgment 150–400 · Ribbon thin.

### Fora de escopo

- Core jobs DTO  
- Reopen strip decision 031  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Rank: failed/cancelled > awaiting choice/external > processing/queued > succeeded > unknown.
2. Exclusive face empty / single / multi / attention(N failed).
3. Ribbon uses ranked agents only.
4. Pack facts top agents + face.
5. Spoken lanes header when multi/attention.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent agents  
- re-order narrative timeline  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire ribbon  
3. Pack optional host  
4. CODEMAP · compress  

Estimativa: **5–7 files · 220–380 LOC**.

## Proof

1. Failed + processing → failed first.  
2. Single agent → single face, no LANES kicker spam optional.  
3. Wire order preserved as secondary key.  
4. DEVICE_PENDING.

## Council

A 047 runner-up #1 after heal-veto. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-049 design.*
