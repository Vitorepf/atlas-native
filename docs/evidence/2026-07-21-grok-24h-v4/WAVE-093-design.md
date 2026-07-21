# WAVE-093 — conversation-can-do-pack-honesty-instrument

**Status:** design · proposed  
**Wave:** `WAVE-093-conversation-can-do-pack-honesty-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Arena (083) e Autônomos (088) fecharam **can_do matrix** por face.
  Conversa mid-thread ainda é **binária** em `ConversationOccasionPack`:
  `ongoing ? .faceCTALocal : .readChat` onde ongoing =
  `matchingLive.contains { $0.timing != .finished }`.
- **Mentiras de can_do:**
  - live finished mas decision/attention CTA ainda publicada → finge só
    readChat ou faceCTA sem matriz;
  - quiet com fila → sem claim de queue CTA;
  - mid-run sem stop/steer publicados → faceCTALocal mentiroso;
  - decision Escolher no strip sem pack subjects.
- Pack mid-thread só chama `ConversationEmptyJudgment.packFacts`.
  **packFacts mortos** (definidos, zero wire no OccasionPack):
  - `ConversationSteerJudgment.packFacts`
  - `ComposerQueueJudgment.packFacts`
  - `PlanJudgment.packFacts`
  - `ConversationAgentLanesJudgment.packFacts`
- `ConversationDecisionJudgment` **sem packFacts** enquanto cockpit eleva
  Escolher.
- Residual strip: labels "Redirecionar"/"Parar" hardcoded no
  `ConversationCockpitBody` (irmão high; fold se barato).

## Patamar

| Antes | Depois |
|---|---|
| can_do bool ongoing | **ConversationCanDoJudgment** matrix |
| Pack só empty facts | Wire steer · queue · plan · lanes · decision |
| faceCTALocal cego | can_do = CTAs **publicadas** |
| Pílula mid-thread mente | Pack ≡ strip/card face |
| ≤5s ask world wrong | Agente responde no poder real da thread |

Δ = **soberania do pack conversa** — último grande can_do surface pack
após 083/088.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Reusa live snapshots, decision judgment, queue messages,
  plan/execution presentation already on bubble/model.
- **Honesty:** never claim stop/steer/choose without published signal;
  never invent queue/plan.
- **Mirror** `AutonomosCanDoJudgment` / Arena occasionCanDo pattern.
- **WAVE-029/084 pétreos:** occasion purity + empty editorial stay.
- Selective packFacts: append when organ signal present; silence when empty.
- Optional: Decision packFacts + strip CTA spoken peel (same domain).

### Fluxo / layout alvo

```
matchingLive + bubble presence + queue + plan? + decision actions?
  → ConversationCanDoJudgment.occasionCanDo
       readChat | faceCTALocal | ctaOnlyRunStop | (status if needed)
  → facts = empty.pack
       + steer.pack? + queue.pack? + plan.pack? + lanes.pack? + decision.pack?
  → absences honest when CTAs absent mid-run
  → ConversationOccasionPack.render
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ConversationCanDoJudgment` | matrix can_do · optional CTA spoken |
| Extend DecisionJudgment | packFacts subjects from actions |
| ConversationOccasionPack | wire matrix + packFacts |

### Arquivos prováveis

- `ConversationCanDoJudgment.swift` (**new**)
- `ConversationOccasionPack.swift`
- `ConversationDecisionJudgment.swift` — packFacts
- Optional `ConversationCockpitBody.swift` — strip CTA spoken from Judgment
- CODEMAP (B)

### Densidade

- Judgment **200–600**
- OccasionPack stays thin composer

### Fora de escopo

- Core cancel/steer APIs  
- Home/Workspace pack rewrite  
- Mega-fuse all conversation judgments  
- Send readiness rewrite (046)  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] can_do **not** only ongoing-bool; matrix from published CTAs.
- [ ] Quiet + no CTA → readChat (not faceCTALocal).
- [ ] Decision actions published → pack subjects + can_do honesty.
- [ ] Queue/plan/lanes/steer packFacts wired when signal present (rg callers).
- [ ] Absences when mid-run without stop/steer.
- [ ] Optional strip spoken ≡ Judgment product words.
- [ ] Gates + CODEMAP conversation can_do pack (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar CTAs  
- tipografia  
- fuse monólito ConversationSurface  
- reabrir empty 084 wholesale  

## Plano W3

1. ConversationCanDoJudgment matrix.  
2. Decision packFacts.  
3. Wire OccasionPack.  
4. Optional cockpit CTA peel.  
5. rg dead packFacts.  
6. CODEMAP (B).  
7. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. Quiet thread → can_do readChat; pack no fake face CTA.  
2. Live stoppable + steer → faceCTALocal/cta stop honesty + facts.  
3. Decision actions → pack lists options; can_do allows choose.  
4. Queue messages → queue packFacts present.  
5. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Sovereignty:** #1 residual max = conversation can_do last surface after
Arena/Autônomos.  
**Arena capabilities confidence** = WAVE-094.  
**Live-control CTA dual strip/card** = runner-up high.

### Runner-ups

1. arena-capabilities-confidence-judgment → 094  
2. conversation-live-control-cta-judgment  
3. arena-run-status-shared-judgment  
4. autonomos-control-receipt-tone  

---

*End WAVE-093 design.*
