# WAVE-027 W3 compress — conversation-presence-primary-chrome

**Date:** 2026-07-21  
**Wave:** WAVE-027  
**Implementer:** Grok B v5

## W2 DoD

| DoD | Proof |
|---|---|
| Primary face words on strip/card/LiveNow | `primarySpoken` lead in ExecutingStrip, StateCard header, LiveNowRow |
| Composer presence-ongoing | `selectPresenceBubble` replaces streaming-only `liveBubble` |
| WAVE-012 dual-surface kept | `ribbonShowsReconnectBanner` + strip reconnect detail secondary |
| AgentRow under face | `agentStatusWord` silences processando/fila; attention words only |
| Glance adapter table | `ConversationExecutionPhase.GlanceAdapter` reconnect/quiet unmapped honesty |
| A11y ≡ face | strip/card/LiveNow spoken lead with `primarySpoken` |
| Timer honesty | unchanged `honestClock` / formatClock — never invent 0:00 |
| CODEMAP | presence primary + selectPresenceBubble |

## W3

1. Elevated Phase helpers (primary + ongoing + selection + glance adapter)
2. Wire composer / strip / card / LiveNow / AgentRow / EditorialTurn ribbon gate
3. No multi-domain fuse; StateCard stays ≤1500

## Density

| File | LOC |
|---|---:|
| ConversationExecutionPhase | ~249 |
| ExecutionStateCard | ~673 |
| ConversationCockpitBody | ~444 |
| LiveNowRow | ~273 |

## DEVICE

DEVICE_PENDING — operator passcode.
