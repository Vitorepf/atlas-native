# WAVE-022 — conversation-execution-phase-grammar

**Status:** design · proposed  
**Wave:** `WAVE-022-conversation-execution-phase-grammar`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v4 dual · idle → one huge residual)  
**Δ patamar:** **high**  
**Rank:** 1  

---

## Problema

WAVE-018 unificou **glance** Island/Lock. A conversa **in-app** ainda fala
execução em dialetos paralelos:

1. `ExecutionRibbon` — reconnect dual-surface, lanes, decide.
2. `ReconnectBanner` / `SilenceWatchdog` — copy e silêncio.
3. `ExecutionStateCard` / strip — progresso e reconnect primary.

O operador julga o run **dentro** e **fora** do app com vozes diferentes.
Não é nova área — é **uma phase grammar** in-app alinhada ao glanceFace.

---

## Patamar

| Antes | Depois |
|---|---|
| Ribbon / strip / watchdog rebrancham | **Uma** face: running · reconnect · paused · finished · multi-agent |
| Dual-surface 012 local | Grammar explícita + silence honesty |
| Continuity Island ≠ conversa | Mesma exclusividade de face |

Δ = Continuity + Conversa agêntica no mesmo órgão de fase.

---

## Arquitetura

### Princípios

- **Casca only.** Presentation phase from ChatBubble / strip state.
- **Exclusive faces** (priority): finished → reconnect → paused → multi-agent → running.
- **WAVE-012 dual-surface:** strip primary owns reconnect copy while streaming; ribbon silent on that copy.
- **Timer honesty** residual if any false 0:00.
- Hosts ≤400.

### Fora de escopo

- Core execution DTO.
- App Group.
- Nova tab.
- Re-chrome pill 016.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `ConversationExecutionPhase.swift` (new) | shared face grammar |
| `ExecutionRibbon.swift` | consume faces |
| `ReconnectBanner` / watchdog sites | silence rules |
| Executing strip if separate | primary reconnect |

### W3

Fuse residual execution peels **−100…−300**.

---

## DoD (≥5)

1. Shared exclusive face enum for conversation execution.
2. Ribbon branches on face (not ad-hoc bool soup).
3. Dual-surface: streaming+reconnect → strip primary, ribbon silence reconnect copy.
4. Multi-agent face when agents≥2.
5. Finished silences reconnect/watchdog noise.
6. A11y spoken ≡ face.
7. Gates; hosts ≤400.

---

## Anti-objetivos

- Invent Core status.
- Opacity ladder.
- Nova área.

---

## Approval

- [x] §B  
- [x] complete  
- [x] approved (implementer self-wave idle)  
