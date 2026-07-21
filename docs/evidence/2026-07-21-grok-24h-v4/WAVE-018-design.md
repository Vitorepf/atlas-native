# WAVE-018 — continuity-island-lock-instrument

**Status:** design · proposed  
**Wave:** `WAVE-018-continuity-island-lock-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **high**  
**Rank:** 3  

---

## Problema

Continuity **glance** (Island + Lock Live Activity) ainda é a maior torre de peels
ActivityKit (~60 files Island/Lock) com gramática de fase **espalhada**:

1. Compact / expanded / minimal / lock cada um rebrancha progress · queue ·
   paused · finished · multi-session.
2. Badges ATT/EXT/FAIL/REC/PLN por substring de `phaseTitle` — ok se **uma**
   árvore; hoje peels micro.
3. Timer honesty residual (falsos 0:00 se `ms` ausente).
4. **App Group / widgets snapshot** permanece **BLOCKED** — esta onda **não**
   restaura Fleet/CodeWeek data. Só **ActivityKit chrome** já vivo via
   ContentState.

Produto: julgar o run **fora do app** em ~3s com a mesma voz do strip in-app
(WAVE-006), sem inventar App Group.

---

## Patamar

| Antes | Depois |
|---|---|
| Island/Lock peel dialects | **Uma** phase grammar ContentState |
| Timer/progress/queue micro | Exclusive faces + honest timers |
| Widget accessories fog | **Out of scope** (App Group) |

Δ = Continuity glance instrument (F3) sem portal.

---

## Arquitetura

### Princípios

- **Casca only** em `App/Widgets` LA + shared ContentState **presentation**.
- **ContentState only** — phaseTitle, progress, queue, paused, finished,
  activeSessions. Sem inventar actions (M89 separate).
- **One phase grammar** shared compact · expanded · minimal · lock.
- **Mutual exclusive faces:** running | paused | finished | multi-session.
- **Timer honesty:** no false 0:00 from missing ms.
- **Deep link** `atlas://execution/…` preserved.
- Hosts ≤400; W3 fuse peels.

### Fora de escopo (pétreo)

- App Group entitlements / snapshot writer / WidgetCenter restore.
- Fleet / LiveSession / CodeWeek accessory data.
- M89 App Intents (design futuro se flags existirem).
- Arena dedicated LA.
- Nova área.

---

## Arquivos (W2)

| Área | Mudança |
|---|---|
| `AtlasTurnLiveActivity+Island*` | One phase grammar |
| `AtlasTurnLockScreen*` | Same grammar |
| Timer peels | Honesty |
| A11y Island/Lock | Spoken ≡ visual |

### W3

| Alvo | Estimativa |
|---|---|
| Island + Lock fuse | **−500…−1200** |

`WAVE-018-compress.md`.

---

## DoD (≥5)

1. Island compact/expanded/minimal = **uma** phase grammar de ContentState.
2. Lock = mesma language (title · badge · progress · queue · timer).
3. Faces exclusivas: running / paused / finished / multi-session.
4. Timer honesty (sem 0:00 falso).
5. Silence when finished/healthy (sem gold fake).
6. Deep link preserved; a11y spoken ≡ visual.
7. Hosts ≤400; gates; **zero** App Group / snapshot claims.

---

## Anti-objetivos

- Continuity restore App Group.
- Island peel rename without phase DoD.
- Fake App Intents buttons.
- Opacity ladder.
- Widget accessories as “done Continuity”.

---

## Plano W3

DoD phase grammar → fuse Island → Lock → timer → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — glance 24/7 |
| DoD≥5 + W3≥500 | **SIM** |
| Casca | **SIM** (ActivityKit) |
| Design | **SIM** |
| Anti-micro | **SIM** (60+ peels) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Scope App Group | critical if | anti explicit |
| M89 creep | major | out |
| False timer | major | DoD4 |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- residual #3 continuity-island-lock  
- Continuity M89 = no (separate)  
- peel debt AtlasTurn yes Δ high  
