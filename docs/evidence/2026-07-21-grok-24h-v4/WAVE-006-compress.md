# WAVE-006 — compress report (W3)

**Wave:** `WAVE-006-conversation-live-composer-instrument`  
**Date:** 2026-07-21  
**Phase:** W3 complete with W2 (fuse = implement)

## Measured Δ (App peel forest → structural hosts)

| Family | Before (approx files) | After | Note |
|---|---|---|---|
| ExecutingStrip + Status* | 17 | 1 | live instrument single tree |
| ReconnectBanner + Bubble helpers | 12 | 2 | banner secondary + bubble helpers |
| ConversationComposer* | 39 | **8** | DoD ≤12 ✓ |
| A11yID execution | +1 id | `executionLiveStrip` | stable strip id |

**Net (git numstat on wave paths):** see commit. Target −400…−900 honest.

## DoD

1. **Um instrumento vivo** — `ExecutingStrip` owns live/progress/reconnect title branch + stop/steer + compound a11y. ✓  
2. **Composer estrutural** — 8 files `ConversationComposer*` (≥1 responsibility each). ✓  
3. **Estados exclusivos na face do strip** — reconnect OR progress OR activity/idle. ✓  
4. **Fail ≠ empty** — untouched EmptyConversation / AtlasNetworkFailureEmpty. ✓  
5. **A11y** — `A11yID.executionLiveStrip`; queueChip/send paths preserved; compound spoken. ✓  
6. **Hosts ≤400** — max composer card 89; strip ~170. ✓  
7. **Gates** — guard + AtlasCoreChecks + make build. ✓

## Residual (honest)

- **ReconnectBanner** still mounts in `ExecutionRibbon` (cockpit) while strip is composer primary. Dual *surface* residual, not dual *copy trees* inside strip. Next: optional silence banner when strip already shows reconnect on same bubble (casca-only).
- **SilenceWatchdog** remains separate secondary in ribbon (subfase live, not strip chrome).
- **ExecutionProof** / **ExecutionStateCard** intentionally out of this wave (design anti-scope).
- Keyboard grabber dead-path deleted (already EmptyView).

## Anti-objectives held

- No Core / ConversationModel logic  
- No empty/fail re-polish  
- No god-file collapse  
- No opacity ladder as compress  
