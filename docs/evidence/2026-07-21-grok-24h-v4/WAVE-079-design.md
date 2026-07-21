# WAVE-079 — conversation-outline-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-079-conversation-outline-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual Outline organ)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ConversationOutlineA11y` owns sheet/empty/row spoken for the outline
  sheet **without pure Judgment**.
- Empty outline vs turns list faces are View-local; pack cannot reuse
  `outline_face: empty|turns`.
- Residual after messages surface (072): **outline navigation organ**
  still dialect soup in ChromeExtras.

## Patamar

| Antes | Depois |
|---|---|
| Spoken helpers local | Exclusive outline face |
| Row spoken local | Judgment row grammar |
| No pack | Pack face + turn count |

Δ = **soberania do sumário de turnos** — empty ≠ lista de turnos.

---

## Arquitetura

### Princípios

- Casca only; bubbles published on model.
- Honesty: empty outline never invents turns.
- One domain: conversation outline sheet (not messages list).

### Fluxo

```
turnCount + bubbles
  → ConversationOutlineJudgment.face / spoken / pack
  → ConversationOutlineA11y peels
```

### Arquivos (≥5)

- `ConversationOutlineJudgment.swift` (**new**)
- `ConversationChromeExtras.swift`
- CODEMAP · design · compress

### Densidade

Judgment 120–240.

### Fora de escopo

- Core chat  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: empty · turns(N).
2. spokenSheet/empty/row/snippet from Judgment.
3. Pack face + turn count.
4. accessibilityValue productWord on outline sheet.
5. Gates + CODEMAP.
6. DEVICE_PENDING.

## Anti-objetivos

- invent turns  
- fuse MessagesJudgment  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Outline A11y  
3. CODEMAP · compress  

Estimativa: **5 files · 180–300 LOC**.

## Proof

1. 0 turns → empty.  
2. N turns → turns face spoken.  
3. row spoken role+snippet.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Outline residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-079 design.*
