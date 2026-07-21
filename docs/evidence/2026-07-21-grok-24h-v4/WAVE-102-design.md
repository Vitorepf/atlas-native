# WAVE-102 — turn-presence-notification-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-102-turn-presence-notification-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `TurnPresence` (511 LOC) embute **4 enums A11y** de notificação
  away (`NotificationA11y` · Body · Spoken · Terminal) no meio do
  runtime LA/broadcast.
- Julgamento terminal / title / body / spoken misturado com side effects
  (UNUserNotificationCenter).
- Residual pós-catalog IDLE-28: Continuity organ incompleto no Judgment.

## Patamar

| Antes | Depois |
|---|---|
| 4 A11y enums in TurnPresence | **TurnPresenceJudgment** pure |
| isTerminal local | Judgment isTerminal |
| lockScreen truncate mixed | Judgment lockScreenText |
| Sem pack notify | pack terminal honesty |

Δ = **soberania da notificação away** — fase/title/body/spoken puros.

---

## Arquitetura

### Princípios

- Casca only. Presence from published AtlasExecutionPresence.
- Judgment pure (Foundation + AtlasCore); no UN/UIKit in Judgment.
- TurnPresence host only wires side effects.
- Zero Core.

### Fluxo

```
AtlasExecutionPresence · excerpt? · detail?
  → TurnPresenceJudgment
       isTerminal · title · body · spoken · lockScreenText · packFacts
  → TurnPresence notifyIfAway / buildAwayNotificationContent
  → delete 4 A11y enums
```

### Arquivos (≥5)

1. `TurnPresenceJudgment.swift` (**new**)
2. `TurnPresence.swift` (delete A11y · wire)
3. `App/Atlas/CODEMAP.md`
4. design.md
5. compress.md
6. LEDGER/DONE/QUEUE

### Densidade

Judgment ~120–180 · TurnPresence −80 A11y soup · agent-optimal

### Fora de escopo

- ActivityKit payload shape  
- Core presence DTO  
- App Group Continuity restore (BLOCKED)  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] TurnPresenceJudgment isTerminal / title / body / spoken.
- [ ] lockScreenText pure on Judgment; TurnPresence may forward.
- [ ] Delete 4 NotificationA11y enums from TurnPresence.
- [ ] buildAwayNotificationContent Judgment-only for text.
- [ ] packFacts for terminal phase honesty.
- [ ] Gates + CODEMAP + DEVICE_PENDING.

## Anti-objetivos

- inventar phase titles  
- mover network  
- Continuity App Group restore  

## Plano W3

1. New Judgment.  
2. Rewire TurnPresence.  
3. Delete A11y block.  
4. CODEMAP Continuity organ.  
5. ~5+ files · ~150–350 LOC.

## Proof

1. Concluído terminal → notify path uses Judgment.isTerminal.  
2. Falhou body uses presentationDetail truncate 140.  
3. Concluído body uses plainText excerpt.  
4. Non-terminal → no notify.  
5. DEVICE_PENDING.

## Council

Residual after file-row-101 + catalog IDLE. Completes Continuity
notification grammar as Judgment organ.

### Rejection

If A11y enums remain or Judgment imports UIKit → fail.

### Density

| Layer | Target |
|---|---|
| TurnPresenceJudgment | 120–200 |
| TurnPresence | −A11y block |

### Terminal rule (honest)

```
timing == .finished
&& (phaseTitle == "Concluído" || phaseTitle == "Falhou")
```

Never invent other phase as terminal for away notify.

### Body rule

| phaseTitle | body source |
|---|---|
| Falhou | presentationDetail |
| Concluído | assistant excerpt plainText |
| else | nil |

### Pack facts

```
presence_terminal: true|false
presence_phase: <title>
absence: notificação away só em terminal
```

### W2 checklist

1. New file Judgment  
2. Wire notify + content  
3. Delete enums  
4. Forward lockScreenText  
5. CODEMAP  
6. Gates  

### W3 checklist

1. compress  
2. DONE 102  
3. regen  
4. waves_completed=97  
5. feat(ui)  

### Risk

- @MainActor TurnPresence calling nonisolated Judgment — OK pure  
- AtlasMarkdown.plainText availability in Judgment  

### Acceptance

- Falhou + detail → body truncated  
- Concluído + excerpt → plain body  
- Executando → isTerminal false  

### Why full-bar

- New Judgment organ · multi-enum delete · Continuity product patamar  
- ≥5 evidence/code files · design ≥120 · DoD ≥5  

---

*End WAVE-102 design.*
