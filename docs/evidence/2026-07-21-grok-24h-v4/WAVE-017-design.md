# WAVE-017 — conversation-editorial-sink-instrument

**Status:** design · proposed  
**Wave:** `WAVE-017-conversation-editorial-sink-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **max**  
**Rank:** 2  

---

## Problema

WAVEs 006 / 012 / 014 fecharam **voar / julgar aftermath / roteiro**. O residual
GOD da conversa é o **sink de leitura** — o caminho diário de **ler** o trabalho
do agente:

1. **ConversationMessages*** (~40 peels) — scroll, FAB, rows, empty glue.
2. **EditorialTurn*** (~34 peels) — user / assistant / execution card / closing.
3. **AtlasMarkdownView*** (~53 peels) — blocks, code, table, inline.
4. **ConversationChrome / View residual** — wiring fog (só o que serve o sink).

Sem isto, o chat de programação com agentes é **ótimo no cockpit** e **névoa no
texto**. Patamar: ler código, decisões e assinatura em ~3s com uma gramática.

---

## Patamar

| Antes | Depois |
|---|---|
| Messages/Editorial/MD peel towers | **Um** message instrument |
| Row → turn dialect | Structural EditorialTurn |
| Markdown micro peels | Readable code surface structural |
| Fail/empty regress risk | 003/008 preserved |

Δ = fechar o ciclo **escrever → voar → ler → julgar** (ler era o buraco).

---

## Arquitetura

### Princípios

- **Casca only.** Zero ConversationModel logic.
- **Não reabrir** 006 strip, 012 proof/state, 014 plan/timeline — glue only.
- **Uma árvore de mensagem:** list · empty · scroll · row → EditorialTurn.
- **Markdown** = substrate do assistant body, fundido sob o sink.
- Fail ≠ empty; load fail shared (008).
- Hosts ≤400; proibido ConversationView god-file monólito.

### Composição alvo

```
ConversationMessageSink
├── empty / load-fail branches (003/008)
├── scroll + FAB
├── rows → EditorialTurn
│     user | assistant(body markdown) | execution card glue | closing
└── a11y compound per turn
```

### Fora de escopo

- Composer redo (006).
- Full ChangeReview (013).
- Island.
- Core multi-GET refresh.
- Nova área.

---

## Arquivos (W2)

| Área | Mudança |
|---|---|
| `ConversationMessages*` | Structural instrument |
| `EditorialTurn*` | Structural states |
| `AtlasMarkdownView*` | Fuse micro; readable blocks |
| Chrome/View residual | Only glue to sink |
| A11y messages/turns | Stable |

### W3

| Alvo | Estimativa |
|---|---|
| Messages + Editorial + Markdown | **−400…−900** |

`WAVE-017-compress.md`.

---

## DoD (≥5)

1. **Message instrument:** list · empty · scroll/FAB · row→EditorialTurn com
   estados exclusivos.
2. **EditorialTurn estrutural:** user · assistant · execution glue · closing —
   zero peels 1-linha.
3. **Markdown estrutural:** blocks · code · table · inline legíveis.
4. Change-review chip glue (se presente) **uma voz** com 013.
5. Fail ≠ empty + 006/012 **sem regressão**.
6. A11y spoken ≡ visual para turns.
7. Hosts ≤400; gates verdes.

---

## Anti-objetivos

- Fuse random Chrome 1-liners sem DoD de sink.
- God-file ConversationView.
- Opacity ladder.
- Re-fuse strip/composer.
- Core edits.

---

## Plano W3

DoD message tree → Editorial → Markdown → delete dead → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — read path agents |
| DoD≥5 + W3≥400 | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** (100+ peels) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Scope strip 006 | major | out |
| Markdown alone as wave | major | only under sink |
| Empty fail regress | critical if | DoD5 |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- residual #2 conversation-editorial-sink  
- peel debt: Conversation* + Markdown top forests  
