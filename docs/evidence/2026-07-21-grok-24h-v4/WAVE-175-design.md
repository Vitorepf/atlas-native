# WAVE-175 — change-review-available-actions-pack-and-can-do

**Status:** design · proposed  
**Wave:** `WAVE-175-change-review-available-actions-pack-and-can-do`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 · anti density-peel)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- **Assinatura humana** na revisão de mudanças: UI publica CTAs letais
  **Aceitar / Rejeitar** de `review.review.availableActions`
  (`ChangeReviewRunActionsBody`) e por arquivo
  (`ChangeReviewFileRowChrome`) — pack mid-thread (WAVE-163) só embute
  **risk/sheet counts**, **não** availableActions / file decisions /
  operatorActions.
- `packGovernanceFacts` existe mas é **a11y sheet dialect**
  (`ChangeReviewGovernanceChrome`) — **não** OccasionPack.
- `ConversationCanDoJudgment` eleva decide/stop/steer/queue — **zero**
  signal de review governance → can_do never faceCTALocal for accept/reject
  even when sheet CTAs published.
- Dual dialect file vs run: file always aceitar/rejeitar when undecided;
  run gated by availableActions; labels differ — pack omits both.
- Same hollow-wire class that maxed stop (157) / strip stop (160) / veto
  (159): **face CTA published, pack mute** → agent invents or refuses wrong.

## Patamar

| Antes | Depois |
|---|---|
| Pack = risk/findings counts only | Pack = **availableActions · file decisions · applying** |
| can_do ignore review CTAs | can_do elevates faceCTALocal when actions published |
| file vs run label dual | Control Judgment one law (file + run) |
| governanceFacts a11y-only | Optional fold into pack organ |
| ≤5s “posso aceitar?” pack mente | Pack ≡ sheet CTAs + absence NL |

Δ = **soberania de assinatura da revisão** — pílula sabe o que a face pode
assinar.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `availableActions`, fileReviews, applying already on model.
- **Honesty:** never invent accept/reject; empty availableActions → silence
  + absence “sem ações publicadas”.
- **NL never applies review** — can_do faceCTALocal + absence “só no sheet”.
- **WAVE-163 pétreo:** risk pack stays; this **adds** control organ.
- One domain: change-review control pack + can_do signal.

### Fluxo / layout alvo

```
PublishedSlice.changeReview (or model reviews when sheet open)
  → ChangeReviewControlJudgment.packFacts(
       availableActions, fileUndecidedCount, applying?)
  → ConversationCanDoJudgment.LiveSignals += hasReviewAccept/Reject
  → occasionCanDo faceCTALocal when actions non-empty
  → OccasionPackOrgans wires control organ next to risk
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ChangeReviewControlJudgment` **or** deepen `ChangeReviewJudgment` | pack control · file/run face · spoken CTA |
| ConversationCanDoJudgment | review signals |
| OccasionPackOrgans | wire |

### Arquivos prováveis

- `ChangeReviewJudgment.swift` / new Control peel
- `ConversationCanDoJudgment.swift`
- `ConversationOccasionPackOrgans.swift`
- `ConversationOccasionPack.swift` — PublishedSlice if needed
- `ChangeReviewRunActionsBody.swift` — only if CTA labels move to Judgment
- Optional FileRowChrome peel spoken
- CODEMAP (B)

### Densidade

- Judgment **200–600**
- Not density peel of Sections monólito

### Fora de escopo

- Core applyChangeReview  
- Invent availableActions  
- Density peels 171–173 style  
- Typography  
- NL write claim  
- Risk re-rank  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Pack mid-thread lists published availableActions (accept/reject honesty).
- [ ] can_do elevates when actions non-empty; absences NL não aplica.
- [ ] Empty availableActions → no fake accept pack.
- [ ] File undecided count optional fact when published.
- [ ] applying state honesty if published.
- [ ] Dual label file/run either unified or pack documents both.
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- density peel  
- invent actions  
- tipografia  
- reabrir risk UI  

## Plano W3

1. Control packFacts from availableActions.  
2. CanDo signals.  
3. Wire OccasionPack.  
4. Optional CTA spoken unify.  
5. CODEMAP (B).  
6. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. Review with accept+reject → pack facts + can_do faceCTALocal.  
2. No availableActions → absence, no invent.  
3. Applying → pack honesty.  
4. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Lethal CTA:** #1 residual max = change-review assinatura pack hollow after
163 risk-only.  
**Search pill host** = WAVE-176.  
**Strip vs StateCard dual** = runner-up high.

### Runner-ups

1. search-agentic-pack-and-pill-host  
2. conversation-live-control-strip-card-unify  
3. composer-send-face-pack  
4. autonomos hub controlApplied face wire  

---

*End WAVE-175 design.*
