# WAVE-095 — conversation-can-do-pack-honesty-instrument

**Status:** design · re-file  
**Wave:** `WAVE-095-conversation-can-do-pack-honesty-instrument`  
**Owner:** casca only (Grok B)  
**Date:** 2026-07-21  
**Created by:** implementer re-file (A WAVE-093 can_do collides NNN with B live-strip 093 DONE)  
**Δ patamar:** **max**  
**Source croqui:** A WAVE-093-design conversation-can-do (verbatim intent)

---

## Problema

(A croqui · collisão NNN 093)

- Arena 083 + Autônomos 088 fecharam can_do matrix.
  Conversa mid-thread ainda binária: `ongoing ? faceCTALocal : readChat`.
- Mentiras: faceCTALocal sem CTA; decision/queue/plan/steer packFacts mortos.
- Residual pack honesty mid-thread.

## Patamar

| Antes | Depois |
|---|---|
| bool ongoing | **ConversationCanDoJudgment** matrix |
| Pack só empty | Wire decision · queue · plan · lanes · live strip |
| faceCTA cego | can_do = CTAs publicadas |

## Arquitetura

```
matchingLive + optional decision/queue signals
  → ConversationCanDoJudgment.occasionCanDo
  → OccasionPack facts + absences
```

## DoD (≥5)

- [ ] can_do matrix not only ongoing-bool
- [ ] Quiet → readChat
- [ ] Live stoppable → cta honesty
- [ ] Decision packFacts when actions
- [ ] Wire dead packFacts (queue/plan/lanes/steer/decision) when signal
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Plano W3

1. ConversationCanDoJudgment  
2. Decision packFacts  
3. Wire OccasionPack  
4. CODEMAP  
5. ~5–8 files

## Note NNN

A 093 design file still holds can_do croqui text; B 093 DONE = live-strip CTAs.
This WAVE-095 re-files can_do organ only.

---

*End WAVE-095 design.*
