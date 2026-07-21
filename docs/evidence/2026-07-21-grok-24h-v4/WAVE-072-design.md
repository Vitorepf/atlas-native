# WAVE-072 — conversation-messages-surface-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-072-conversation-messages-surface-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual Messages organ)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ConversationMessages` empty path (load failure vs empty conversation)
  + list spoken counts live **without pure Judgment** for the messages
  surface organ.
- Load failure / empty invite / messages list faces are View-local;
  pack cannot reuse `messages_face: loading_fail|empty|messages`.
- Residual after steer/send/stale-read instruments: **timeline messages
  organ** still dialect soup.

## Patamar

| Antes | Depois |
|---|---|
| if loadError soup | Exclusive messages face |
| Spoken count local | Judgment spoken |
| No pack | Pack face + turn count |

Δ = **soberania da lista de mensagens** — falha ≠ vazio ≠ turns.

---

## Arquitetura

### Princípios

- Casca only; loadError + bubbles published on model.
- Honesty: empty ≠ invent turns; fail uses published failure empty.
- One domain: conversation messages surface (not steer/send).

### Fluxo

```
loadError? + bubbleCount
  → ConversationMessagesJudgment.face / spoken / pack
  → ConversationMessages peels
```

### Arquivos (≥5)

- `ConversationMessagesJudgment.swift` (**new**)
- `ConversationMessages.swift`
- CODEMAP
- design + compress

### Densidade

Judgment 120–240.

### Fora de escopo

- Core chat load  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: load_fail · empty · messages(N).
2. spokenMessages from Judgment.
3. spokenChangeReview peel if already local stays or routes Judgment.
4. Pack face + turns.
5. accessibilityValue productWord on list chrome.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent bubbles  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Messages  
3. CODEMAP · compress  

Estimativa: **5 files · 180–300 LOC**.

## Proof

1. loadError → load_fail.  
2. empty bubbles → empty.  
3. N turns → messages.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Messages residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-072 design.*
