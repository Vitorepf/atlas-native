# WAVE-045 — conversation-handoff-continuity-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-045-conversation-handoff-continuity-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ConversationHandoffReceipt` embeds face/copy/spoken for surface handoff
  **inside the View** — no pure `ConversationHandoffJudgment`.
- Status `ready` / `pending` / other are bools on the View; unknown statuses
  fall through without exclusive face product word.
- Continuity copy helpers (`atlasHandoffStatusEditorial`) are free functions
  without pack grammar for occasion hosts.
- Operator judges continuity from one receipt, but IA/pack cannot reuse the
  same face without scraping View.
- Residual after Autônomos transfer handoff (035): **conversation surface
  continuity** still lacks Judgment organ.

## Patamar

| Antes | Depois |
|---|---|
| isReady/isPending on View | Exclusive face on Judgment |
| Headline/subline View-owned | Judgment pure |
| Spoken ad hoc | spokenFace + summary |
| No pack | pack route/thread/status |

Δ = **soberania da continuidade** — ready vs enviando vs outro status.

---

## Arquitetura

### Princípios

- Casca only; `AtlasAiSurfaceHandoff` fields only.
- Honesty: unknown status → `.other(raw)` face, never invent ready.
- Labels still via `atlasSurfaceLabel` presentation helpers.
- One domain: conversation continuity handoff.

### Fluxo

```
model.latestSurfaceHandoff
  → ConversationHandoffJudgment.face / headline / subline / spoken / pack
  → ConversationHandoffReceipt consumes Judgment
  → optional Occasion pack hook if host already packs thread
```

### Módulos

| Nome | Papel |
|---|---|
| `ConversationHandoffJudgment` | face · copy · pack · spoken |
| `ConversationHandoffReceipt` | thin chrome |
| ContinuityCopy | keep surface labels |
| CODEMAP | handoff face |

### Arquivos (≥5)

- `ConversationHandoffJudgment.swift` (**new**)
- `ConversationChromeExtras.swift` — wire
- `ConversationSurface.swift` — optional if needed
- `A11yID` if new face id
- `CODEMAP.md`
- design + compress

### Densidade

Judgment 200–500 · Receipt thin.

### Fora de escopo

- Core handoff DTO  
- App Group Continuity BLOCKED  
- Autônomos transfer rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: absent · pending · ready · other(raw).
2. Receipt headline/subline/spoken from Judgment only.
3. Pack facts: status, route, thread prefix, age if published.
4. Unknown status not labeled ready.
5. A11y uses Judgment spoken.
6. CODEMAP + gates.
7. DEVICE_PENDING.

## Anti-objetivos

- invent ready  
- Core  
- fuse with AutonomosTransferJudgment  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire receipt  
3. CODEMAP  
4. compress · DONE · regen  

Estimativa: **5–7 files · 250–380 LOC**.

## Proof

1. ready → face ready + "Pronto no …"  
2. pending → face pending + spin still View chrome  
3. other status → other face, editorial raw  
4. DEVICE_PENDING  

## Council

Post-044 empty queue. Continuity residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-045 design.*
