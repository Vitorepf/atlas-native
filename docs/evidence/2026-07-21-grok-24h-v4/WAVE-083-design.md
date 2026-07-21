# WAVE-083 — arena-live-can-do-pack-honesty-instrument

**Status:** design · proposed  
**Wave:** `WAVE-083-arena-live-can-do-pack-honesty-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- `ArenaPremiumAskContext` **hardcode** `canDo: .ctaOnlyRunStop` em
  **todo** tab/destination — idle, fleet, capabilities, results, plan
  claim the same control grammar as live stop.
- **Judgment APIs shipped unused:** `ArenaNowJudgment.packFacts` e
  `ArenaLiveControlJudgment.packFacts` existem com `can_stop` fact —
  **quase zero callers** no pack host (Autônomos já liga packLoopFacts;
  Arena não).
- Pack monta `fase_ao_vivo` ad hoc; UI faces usam Now/LiveControl product
  words → **face vs pack dual dialect**.
- **canStop dual law:** `ArenaPremiumExecutionView` usa
  `ArenaLiveControlJudgment.canStop`; `ArenaPremiumRunningView` reimplementa
  `run.canStop + measurementIdPublic` — duas leis de parada.
- Residual nomeado desde WAVE-065 council — now/live organs closed;
  **can_do pack honesty unpaid**.

## Patamar

| Antes | Depois |
|---|---|
| can_do sempre ctaOnlyRunStop | can_do **from faces** (idle browse ≠ stop) |
| packFacts Judgment mortos | AskContext **wire** Now + LiveControl packFacts |
| canStop dual | **uma** lei Judgment |
| Pílula mente “pode parar” idle | can_do + facts honestos por tab |
| ≤5s ask world wrong | Pack ≡ Agora/Execução face |

Δ = **soberania do pack Arena** — can_do e facts = o que a face permite.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Wire existing Judgment packFacts + canStop; extend
  `AgenticOccasionPack.CanDo` **only if** existing cases insufficient
  (prefer map: idle/browse → `readChat`; stoppable → `ctaOnlyRunStop`;
  face CTAs → `faceCTALocal`).
- **Honesty:** never claim stop when no stoppable primary; never claim
  start NL write.
- **WAVE-066/050 pétreos:** Now + LiveControl faces stay source of truth.
- **WAVE-082 sibling:** plan/queue face pack may compose; don't block
  on 082 if destination.plan can use planFace when present.
- Silence when domain unavailable (existing).
- Um domínio: Arena occasion pack honesty.

### Fluxo / layout alvo

```
tab + destination + livePresentation + primaryRun
  → nowFace = ArenaNowJudgment.face(...)
  → liveFace / canStop = ArenaLiveControlJudgment
  → canDo =
       stoppable live → ctaOnlyRunStop
       startable idle (if start CTA published) → faceCTALocal or readChat+absence
       browse results/fleet/capabilities → readChat
  → facts = Now.packFacts + LiveControl.packFacts + destination facts
  → RunningView.canStop → Judgment.canStop only
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| Extend AskContext | canDo matrix + packFacts wire |
| Existing Now/LiveControl Judgments | packFacts · canStop |
| Optional thin `ArenaOccasionJudgment` | only if matrix needs pure home |

### Arquivos prováveis

- `ArenaPremiumAskContext.swift` — can_do + facts honesty
- `ArenaNowJudgment.swift` — ensure packFacts complete (no logic invent)
- `ArenaLiveControlJudgment.swift` — packFacts + canStop
- `ArenaPremiumRunningView.swift` — peel dual canStop
- `ArenaPremiumExecutionView.swift` — parity
- `AgenticOccasionPack.swift` — only if CanDo needs case
- CODEMAP (B)

### Densidade

- AskContext shrinks hardcode  
- No new monólito  
- Judgment growth small if any  

### Fora de escopo

- Core endpoints  
- Plan/queue face organ (082)  
- Pipeline glyph polish alone  
- Autônomos can_do (separate residual)  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] canDo **not** always ctaOnlyRunStop; matrix by face/tab.
- [ ] AskContext calls Now + LiveControl **packFacts** (rg callers >0).
- [ ] can_stop fact matches Judgment.canStop(primary).
- [ ] RunningView uses Judgment.canStop only (no dual law).
- [ ] Browse destinations (results/fleet/capabilities) → readChat (or honest status).
- [ ] Spoken/pack absence when stop unavailable.
- [ ] Gates + CODEMAP arena pack honesty (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar CanDo write NL  
- tipografia  
- reabrir Now phase chrome  
- fuse multi-domínio  

## Plano W3

1. Define canDo matrix pure (in AskContext helper or thin Judgment).  
2. Wire packFacts.  
3. Peel RunningView canStop.  
4. rg hardcode ctaOnlyRunStop only where face allows.  
5. CODEMAP (B).  
6. Estimativa: **~5–8 files · ~250–500 LOC**.

## Proof / device

1. Arena idle/fleet → pack can_do readChat (not stop claim).  
2. Live stoppable → ctaOnlyRunStop + can_stop true.  
3. Stopping / no measurementId → can_stop false honesty.  
4. packFacts include phase product words = Now face.  
5. DEVICE_PENDING se passcode.

## Council

**Sovereignty explore:** #2 residual max = Arena packFacts unused + static
can_do (named since 065).  
**082** owns plan UI/pack face; **083** owns can_do/live pack wire.  
**Conversa** empty/draft = high runners-up.

### Runner-ups

1. conversation-empty-editorial-judgment  
2. composer-draft-attachment-judgment  
3. codigo-worktrees-rank  
4. autonomos can_do always faceCTALocal  

---

*End WAVE-083 design.*
