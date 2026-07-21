# WAVE-107 — arena-run-status-shared-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-107-arena-run-status-shared-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Residual **nomeado** desde WAVE-085 plan/queue e 093/094 councils:
  `AtlasArenaRunStatus` chrome ainda é **View-owned triplicado**:
  - `ArenaPremiumExecutionView`: `statusLabel` · `statusTone` · `rowGlyph` ·
    `rowTrailing` · `tone(status)`
  - `ArenaPremiumRunDetailView`: dual `statusLabel` / `statusTone` /
    `summaryLine`
  - `ArenaPremiumIcon.run` / `planStatus` glyph irmão
  - `ArenaPlanQueueJudgment.suiteTone` partial — not full status organ
- `ArenaLiveControlJudgment` owns face/rank/canStop — **não** row/detail
  chrome product words.
- Operador lê kicker de execução, row e detail em **dialetos paralelos**.
- Optional fold cheap: pipeline projection stays separate residual (high,
  not this WAVE’s monólito).

## Patamar

| Antes | Depois |
|---|---|
| 3+ switches status na View | **ArenaRunStatusJudgment** one law |
| Detail ≠ Execution kicker | Mesmo label/tone/glyph |
| Icon/planStatus irmão solto | Glyph from Judgment |
| Pack run status ad hoc | pack product word from Judgment |
| ≤5s status mente | Uma língua corrida |

Δ = **soberania do status da corrida** — Execution ≡ Detail ≡ Icon.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `AtlasArenaRunStatus` published.
- **Honesty:** unknown status → neutral silence; never invent progress %.
- **One domain:** run status chrome (not plan suite rollup rewrite).
- Reuse suiteTone only if maps cleanly; don’t break PlanQueue 085.
- LiveControl face remains for list rank/canStop.

### Fluxo / layout alvo

```
AtlasArenaRunStatus (+ optional run for trailing)
  → ArenaRunStatusJudgment
       label · tone · glyph · rowTrailing · summaryLine · packWord · spoken
  → ExecutionView / RunDetailView / Icon peels
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ArenaRunStatusJudgment` | exclusive status chrome law |
| ExecutionView · RunDetailView · Icon | wire |

### Arquivos prováveis

- `ArenaRunStatusJudgment.swift` (**new**)
- `ArenaPremiumExecutionView.swift`
- `ArenaPremiumRunDetailView.swift`
- `ArenaPremiumIcon.swift`
- Optional PlanQueue suiteTone align
- CODEMAP (B)

### Densidade

- Judgment **150–400**
- Views lose private switches

### Fora de escopo

- Core  
- Stop sheet full organ (runner-up)  
- Pipeline monólito fuse  
- Micro tipografia  
- LiveControl rank rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Exclusive label/tone/glyph from Judgment for all run statuses.
- [ ] Execution kicker ≡ Detail kicker product words.
- [ ] rowGlyph/rowTrailing from Judgment.
- [ ] Icon.run uses Judgment glyph (or thin adapter).
- [ ] Unknown → silence/neutral honesty.
- [ ] Optional packWord for Ask if cheap.
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar status  
- tipografia  
- fuse Pipeline+Stop+Execution monólito  
- reabrir plan/queue 085 wholesale  

## Plano W3

1. Extract dual switches → Judgment.  
2. Wire Execution + Detail.  
3. Wire Icon.  
4. rg private statusLabel.  
5. CODEMAP (B).  
6. Estimativa: **~5–8 files · ~280–500 LOC**.

## Proof / device

1. Running/stopping/failed/completed same words on list + detail.  
2. Row glyph matches kicker tone family.  
3. Unknown status no crash/fake.  
4. DEVICE_PENDING se passcode.

## Council

**Arena:** #1 residual max status shared (unpaid since 085).  
**106** mid-thread pack hydration max conversation.  
**Stop sheet governance** runner-up after this.

### Runner-ups

1. arena-stop-governance-judgment  
2. arena-execution-pipeline-judgment  
3. home-live-now-row-spoken  
4. composer-queue-row-judgment  

---

*End WAVE-107 design.*
