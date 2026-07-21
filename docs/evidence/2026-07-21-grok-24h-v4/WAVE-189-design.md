# WAVE-189 — composer-queue-row-action-and-can-do

**Status:** design · proposed  
**Wave:** `WAVE-189-composer-queue-row-action-and-can-do`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 · anti density-peel)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Fila mid-run publica CTAs de face **promote** (“enviar agora”) e
  **remove** no sheet (`QueuedFollowUpRowBody` → `model.promote` /
  `removeQueued`) — pack só inventário (`queue_face` · count · head · tail).
- `ConversationCanDoJudgment` com `hasQueue` sozinho retorna **`.readChat`**
  (comentário: “queue alone does not authorize write”) enquanto a face tem
  CTAs de reordenação — **under-claim** vs WAVE-175 (review → faceCTALocal
  + absence “NL não aplica”).
- Product words de promote/remove/position (**próxima na fila / Nª**) vivem
  só na View; `ComposerQueueJudgment` declara explicitamente não cobrir
  promote grammar — dual law chip/sheet vs row.
- Mesma classe hollow-wire que maxeou stop (157) / review assinatura
  (175): **face CTA publicada, pack/can_do mudos ou mentirosos**.

## Patamar

| Antes | Depois |
|---|---|
| pack = count/head only | pack = **promote/remove available** + ordinal honesty |
| can_do readChat se só fila | can_do **faceCTALocal** + absence “só no sheet da fila” |
| promote labels View-owned | **ComposerQueueJudgment** row action grammar |
| Agent invents/refuses promote | Pack ≡ sheet CTAs |
| ≤5s reordenar fila pack-cego | Soberania FIFO nomeada |

Δ = **soberania da fila mid-run** — o que a face pode promover, a pílula
sabe (sem NL write).

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `QueuedMessage` list already published; model owns
  promote/remove order (not re-rank in Judgment).
- **Honesty:** empty queue → silence; never invent promote without messages.
- **NL never promotes** — faceCTALocal + absence “promote/remove só no sheet”.
- **WAVE-051/178 pétreos:** chip/head/send face stay; this **adds** row
  action + can_do law.
- One domain: composer queue actions.

### Fluxo / layout alvo

```
queuedMessages
  → ComposerQueueJudgment.rowActionFacts(messages)
       promote_available / remove_available / head_ordinal words
  → packFacts append CTA product words
  → ConversationCanDoJudgment: hasQueue → faceCTALocal
       + absences "fila: ações no sheet (enviar agora / remover); NL não reordena"
  → QueuedFollowUpRowBody labels from Judgment.promoteLabel(index, text)
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| Deepen `ComposerQueueJudgment` | row promote/remove/position spoken + pack CTA |
| `ConversationCanDoJudgment` | queue → faceCTALocal + absences |
| Row body | wire labels |

### Arquivos prováveis

- `ComposerQueueJudgment.swift`
- `ConversationCanDoJudgment.swift`
- `ConversationOccasionPackLive.swift` (queue pack already called)
- `QueuedFollowUpRowBody.swift`
- `QueuedFollowUpsSheetBody.swift` (optional sheet spoken)
- CODEMAP (B)

### Densidade

- Judgment **200–500**
- Not peel monólito composer

### Fora de escopo

- Core promote API / reorder invent  
- Density peels  
- Typography  
- NL write claim  
- Send face rewrite (178)  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] packFacts includes promote/remove availability when queue non-empty.
- [ ] can_do with queue alone → faceCTALocal (not bare readChat under-claim).
- [ ] Absences: NL não reordena; ações no sheet.
- [ ] Row promote/remove/position spoken from Judgment (View peels only).
- [ ] Empty queue → no fake promote facts.
- [ ] Head ordinal honesty (1ª = próxima).
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- invent reorder  
- density peel  
- tipografia  
- reabrir chip-only 051  

## Plano W3

1. Row action + packFacts deepen Queue Judgment.  
2. CanDo matrix queue → faceCTALocal + absences.  
3. Wire RowBody labels.  
4. rg View-owned promote strings.  
5. CODEMAP (B).  
6. Estimativa: **~5–8 files · ~280–500 LOC**.

## Proof / device

1. Queue 2+ → pack promote_available; can_do faceCTALocal.  
2. Empty queue → readChat / silence promote.  
3. Row a11y ≡ Judgment product words.  
4. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Sovereignty:** #1 residual max = queue face CTAs + can_do under-claim after
175 review pattern.  
**Autônomos catalog empty pack** / **strip-card unify** = WAVE-190.  
**WAVE-188** open high (thread-live + destination) — keep.

### Runner-ups

1. autonomos-catalog-list-pack-honesty (units:[] hardcode)  
2. conversation-live-control-strip-card-unify  
3. autonomos hub controlApplied face wire  
4. ChangeReviewControl face labels dual  

---

*End WAVE-189 design.*
