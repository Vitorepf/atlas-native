# WAVE-106 — conversation-mid-thread-pack-live-hydration

**Status:** design · proposed  
**Wave:** `WAVE-106-conversation-mid-thread-pack-live-hydration`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-095 / can_do pack **claimam honesty**, mas o mid-thread pack ainda
  **hidrata oco**:
  - `ComposerQueueJudgment.packFacts(from: [])` — fila sempre vazia no pack
  - `PlanJudgment.packFacts(plan: nil, progress: nil)` — plano sempre ausente
  - `ConversationAgentLanesJudgment.packFacts(from: [])` — lanes sempre vazias
  - Decision/can_do signals derivados **só** de `matchingLive` hub sessions,
    não do `ConversationModel` (presence bubble · queuedMessages · plan · agents)
- Route thread fecha `turnFacts` sobre **session only**:
  `RootChromeFace` → `{ [session] _ in ConversationOccasionPack.facts(session:…) }`
  — **nunca** captura o model vivo (Autônomos já faz model-capture pattern).
- UI mostra Escolher / Parar / fila chip / plano no card; pílula mid-thread
  ouve “fila vazia / plano não publicado / sem decisão” → **UI ≠ pack**
  após onda “done”. Maior residual de soberania pós-095.
- Casca only: rebind `model.turnFacts` após seed para fechar sobre model;
  estender `OccasionPack.facts` com slice publicado (bubble?, queue, …).

## Patamar

| Antes | Depois |
|---|---|
| packFacts com arrays nil/[] | packFacts de **queue · plan · lanes · decision** reais |
| turnFacts session-only | turnFacts captura **ConversationModel** mid-thread |
| can_do de hub LiveSession only | can_do de presence bubble + CTAs publicadas |
| Pílula mente quiet | Pack ≡ strip/card/queue |
| ≤5s ask world wrong | Agente vê o mesmo mundo que o olho |

Δ = **soberania mid-thread real** — fecha o buraco oco da WAVE-095.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `ConversationModel` fields already @Observable public
  (bubbles, queuedMessages, turnFacts setter).
- **Honesty:** never invent plan/queue/agents; if model not bound yet,
  absence “model ainda não hidratado” not fake empty organs forever.
- **Pattern:** Autônomos MapShell ask already closes over model — copy law.
- **WAVE-095/093 pétreos:** CanDoJudgment matrix stays; this **feeds** it.
- Prefer `ConversationDecisionJudgment.packFacts(from: bubble)` when bubble
  available.
- One domain: occasion pack hydration — not redesign strip.

### Fluxo / layout alvo

```
ConversationView / Surface seed
  → model.turnFacts = { [model, session, threadId, title] _ in
        ConversationOccasionPack.facts(
          session:,
          threadId:, title:,
          published: .init(
            presenceBubble: model.selectPresenceBubble…,
            queued: model.queuedMessages,
            plan/progress from bubble,
            agents from bubble
          )
        )
     }

OccasionPack.facts(..., published?)
  → LiveSignals from bubble+queue+live hub
  → CanDoJudgment.packFacts(real signals)
  → Queue/Plan/Lanes/Decision/Strip packFacts with real data
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ConversationOccasionPack.PublishedSlice` (or similar) | optional hydration payload |
| Extend CanDo `liveSignals` | accept bubble/queue not only hub sessions |
| ConversationSurface / RootChromeFace | rebind turnFacts |

### Arquivos prováveis

- `ConversationOccasionPack.swift` — PublishedSlice + real packFacts
- `ConversationCanDoJudgment.swift` — signals from published slice
- `ConversationSurface.swift` — model.turnFacts bind
- `RootChromeFace.swift` — pass-through or stop session-only override
- Optional DecisionJudgment `packFacts(from: ChatBubble)`
- CODEMAP (B)

### Densidade

- Pack growth honest; no monólito Surface multi-domain

### Fora de escopo

- Core endpoints  
- Redesign strip chrome  
- Home/Workspace partida packs  
- Micro tipografia  
- Fuse all conversation judgments  

### §5

`nenhum` se model fields públicos bastam.

---

## DoD produto (≥5)

- [ ] Mid-thread turnFacts **não** passa sempre queue=[] / plan=nil.
- [ ] Com fila real, packFacts queue refletem count/head.
- [ ] Com plan no bubble, pack plan facts presentes.
- [ ] Com agents, lanes packFacts presentes.
- [ ] can_do reflects strip CTAs (decision/stop) when bubble publishes.
- [ ] Session-only path still works for hosts without model (honest absence).
- [ ] Gates + CODEMAP mid-thread pack hydration (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar fila/plano  
- tipografia  
- reabrir 095 só rename  
- ConversationModel logic edit (Codex) — only turnFacts binding  

## Plano W3

1. PublishedSlice type + OccasionPack overload.  
2. CanDo signals from slice.  
3. Wire Surface model.turnFacts.  
4. Fix RootChromeFace thread destinations.  
5. rg empty packFacts(from: []) mid-thread.  
6. CODEMAP (B).  
7. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. Thread with live + queue → pack mentions fila.  
2. Decision actions → pack subjects + can_do choose.  
3. Plan card visible → pack plan face not “não publicado”.  
4. Quiet empty thread → honest absences.  
5. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Sovereignty:** #1 residual max = hollow mid-thread pack after claimed 095.  
**Arena run-status shared / stop sheet** = WAVE-107.  
**Plan-card spoken 105** already proposed high.

### Runner-ups

1. arena-run-status-shared-judgment → 107  
2. arena-stop-governance-judgment  
3. home-live-now-row-spoken  
4. composer-queue-row-judgment  

---

*End WAVE-106 design.*
