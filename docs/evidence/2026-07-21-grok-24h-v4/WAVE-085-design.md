# WAVE-085 — arena-plan-queue-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-085-arena-plan-queue-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Destinos **Plano / Fila** da Arena ainda são **state machine na View**
  (`ArenaPremiumPlanQueueViews`): união live∪queue, rollup de status por
  suíte (`running → stopping → queued → failed → all-completed → stopped`),
  tone map, empty kickers — **zero pure Judgment**.
- **Mentira pack vs UI:** quando `activePlan == nil` mas há runs vivos, a
  UI deriva plano das corridas (comentário no código admite o antigo
  “nenhum plano” contraditório). O pack (`ArenaPremiumAskContext`) só
  diz `plano_ativo: sim` se `activePlan != nil`, senão absence
  *"sem plano multi-suíte publicado"* — **operador vê suítes; pílula
  jura que não há plano**.
- Mesma classe de falha de soberania que WAVE-064 (hub vs pack vs entry
  divergem).
- Pós-050 live-control · 059 suite · 066 now · 074 run-sheet: residual
  **plan/queue organ** ainda dialeto View.
- Run detail / execution row status maps (glyph/tone) são residual
  irmão — prefer **um** `ArenaRunStatusJudgment` compartilhado se barato
  na mesma passagem; senão peels plan/queue first.

## Patamar

| Antes | Depois |
|---|---|
| planStatus/planTone na View | **ArenaPlanQueueJudgment** exclusive faces |
| Pack “sem plano” vs UI derived | Pack face: `published` \| `derived_live` \| `empty` |
| Fila empty ad hoc | queue face empty \| active(N) |
| Dialeto suíte triplo | label/tone/glyph de Judgment (ou RunStatus shared) |
| ≤5s plano ≠ pílula | Uma língua Plano · Fila · pack |

Δ = **soberania do plano/fila Arena** — o que a tela mostra é o que a
pílula sabe.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `activePlan`, `arenaPrimaryMeasurementRuns`, queued runs
  já no `ArenaModel`.
- **Honesty:** never invent suite progress; `derived_live` is explicit
  face (not fake `activePlan`); empty silence when no signal.
- **One domain:** plan+queue judgment (same file ok if same status law).
- Optional extract `ArenaRunStatusJudgment` for label/tone/glyph shared
  with ExecutionView/RunDetail — only if ≥2 consumers in this wave.
- Pack law 020: surface arena · destination plan|queue · face facts.
- WAVE-050/066 pétreos: live-control rank + now phase stay.

### Fluxo / layout alvo

```
activePlan? + primaryMeasurementRuns + queuedRuns
  → ArenaPlanQueueJudgment.planFace
       empty | published(plan) | derived_live(suites)
  → suiteStatus(suite) / tone / rank from published runs
  → queueFace empty | active(n)
  → PlanView / QueueView peels
  → AskContext plan|queue uses same face (not activePlan bool only)
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ArenaPlanQueueJudgment` | planFace · queueFace · suiteStatus · tone · pack · spoken |
| Optional `ArenaRunStatusJudgment` | shared status chrome if Execution/Detail peel same wave |
| Existing | PlanQueueViews, AskContext, LiveControl for run rank |

### Arquivos prováveis

- `ArenaPlanQueueJudgment.swift` (**new**)
- Optional `ArenaRunStatusJudgment.swift` (**new** if multi-consumer)
- `ArenaPremiumPlanQueueViews.swift` — peel SM
- `ArenaPremiumAskContext.swift` — plan/queue pack honesty
- `ArenaPremiumExecutionView.swift` / `ArenaPremiumRunDetailView.swift` —
  only if shared status judgment
- `ArenaPremiumIcon.swift` — status symbol via Judgment if touched
- CODEMAP (B)

### Densidade

- Judgment **200–700**
- PlanQueueViews shrinks dialect
- Fail if Arena monólito multi-domínio

### Fora de escopo

- Core invent `activePlan` wire  
- can_do pack global (WAVE-083 sibling)  
- Micro tipografia / fuse-as-WAVE  
- Re-litigate suite sheet 059 / now 066  
- Continuity App Group  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Exclusive planFace: empty · published · derived_live.
- [ ] Pack mirrors planFace (nunca “sem plano” se UI derived_live).
- [ ] suiteStatus/tone from Judgment (View peels only).
- [ ] queueFace empty|active; spoken from Judgment.
- [ ] Honesty: no invented suite progress.
- [ ] Optional: Execution/Detail status shared if same Judgment.
- [ ] Gates + CODEMAP plan/queue organ (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar plano Core  
- tipografia  
- fuse Now+Plan+Pipeline monólito  
- só rename sem pack honesty  

## Plano W3

1. Extract suite rollup + faces → Judgment.  
2. Wire Plan/Queue views.  
3. Wire AskContext pack.  
4. Optional shared run status peel.  
5. rg dual dialect plano_ativo.  
6. CODEMAP (B).  
7. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. activePlan nil + live runs → UI derived_live + pack **não** absence
   “sem plano”.  
2. activePlan published → face published + pack plano_ativo.  
3. Quiet → empty silence both.  
4. Queue multi → face active(N).  
5. DEVICE_PENDING se passcode.

## Nota de colisão

WAVE-082 número foi consumido por compress paralelo `execution-proof-quality` (implementer self-WAVE) enquanto o croqui plan/queue vivia no mesmo NNN. **Re-proposto como 085** para não perder o residual max.

## Council (2026-07-21 · ≥3 explore)

**Arena/Código:** #1 residual max = plan/queue View SM + pack lie.  
**can_do static** = WAVE-083.  
**Conversa:** empty editorial / draft strip = runners-up high.  
WAVE-081 composer sheet done.

### Runner-ups

1. `arena-live-can-do-pack-honesty` → 083  
2. `conversation-empty-editorial-judgment`  
3. `composer-draft-attachment-judgment`  
4. `codigo-worktrees-rank-judgment`  
5. `autonomos-control-receipt-tone`  

---

*End WAVE-082 design.*
