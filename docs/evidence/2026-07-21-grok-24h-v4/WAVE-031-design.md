# WAVE-031 — conversation-decision-control-instrument

**Status:** design · proposed  
**Wave:** `WAVE-031-conversation-decision-control-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- O momento de soberania máxima **in-thread** é
  `attention_required` / `awaiting_user_choice`. Core já trata como
  **paused** + "Aguardando decisão" e publica **choice actions** +
  `resume-choice` (`resolveExecutionChoice` no model).
- Casca ainda se comporta como cockpit de run **ao vivo**:
  - **Composer strip** (`ExecutingStrip`): só **Redirecionar / Parar** —
    sem **Escolher** quando `state.actions` existem.
  - **ExecutionStateCard**: tem choice buttons reais — mas **enterrados**
    no scroll da árvore de mensagens.
  - **`face(for: state)`**: `attentionRequired` → **`.running`** enquanto
    Core/timer dizem paused + badge card **PAUSADO** → dialeto mentiroso
    ("execução ao vivo" + "decisão necessária" em conflito).
  - **LiveNow**: `paused` + phaseTitle detail; abre thread **sem** verbo
    de decisão no hub.
- WAVE-026 (Autônomos) e WAVE-030 (loop control) fecham frota. Residual
  **conversa** = operador **não julga a escolha no strip** em ≤5s —
  gêmeo de "Pede você without CTA was a lie".
- WAVE-027 fechou vocabulary primary chrome (presence). WAVE-029 fechou
  occasion pack. **Não** fecharam o órgão de **escolha**.

## Patamar

| Antes | Depois |
|---|---|
| Strip = Parar/Redirecionar only | Strip eleva **Escolher** / action titles quando actions publicadas |
| StateCard only place to decide | Strip primary + card = mesma decision face |
| attentionRequired face = running | Face/attention honesty: **decision** lead, not live-run dialect |
| LiveNow sem verbo de decisão | Lead word decision + open thread (CTA honesty) |
| Operador caça botão no scroll | Operador **decide em ≤5s** do strip/hub |

Δ = soberania de **julgamento mid-run na conversa** — human escolhe o ramo
publicado; silêncio se actions não publicadas (zero theater de inbox).

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `executionPresentationState`, `state.actions`,
  `executionChoiceJobId`, `model.resolveExecutionChoice` já existem.
- **Honesty:** sem actions / sem jobId → silence Escolher; keep stop/steer
  se presence ongoing; never invent options.
- **Attention overlays (023)**: `.decision` já existe — **elevar a primary
  chrome** quando presente; não criar segundo enum de face se dá para
  mapear attention → lead copy. Prefer: face paused (Core truth) +
  attention decision lead, **ou** product line "decisão" over running.
- **WAVE-012 dual-surface pétreo** (reconnect strip ownership).
- **WAVE-027 presence primary** pétreo — esta onda **consome** face/attention
  machine; não re-litigar vocabulary global.
- **Pack:** se turnFacts mid-decision, anchors/can_do incluem choice CTA
  local (029 OccasionPack path) — deepen, don't fork.
- Um domínio: Conversation decision judgment — não misturar Autônomos.

### Fluxo / layout alvo

```
ChatBubble.executionPresentationState
  + executionChoiceJobId + state.actions
        │
        ▼
ConversationDecisionJudgment (pure)
  · isDecisionRequired(bubble/state)
  · primarySpoken = attention.decision when present
  · choiceActions | silence if unpublished
  · stripPrimary: Escolher / first action titles
  · demote stop/steer to secondary when decisionRequired
        │
        ├─ ExecutingStrip  → elevate choose; stop secondary
        ├─ ExecutionStateCard → primary header = decision (not running)
        ├─ face(for: state) honesty: attentionRequired ≠ pure running
        ├─ LiveNowRow → decision lead word when mappable
        └─ a11y spoken ≡ decision product words
```

### Tipos / módulos a criar ou elevar

| Nome | Papel |
|---|---|
| `ConversationDecisionJudgment` (new pure) **or** grow Phase | isDecisionRequired · strip actions · primary spoken |
| `ConversationExecutionPhase` | fix face map attentionRequired; spoken decision lead |
| Existing | `resolveExecutionChoice`, StateCard choice buttons, ExecutingStrip |

### Arquivos prováveis

- `ConversationDecisionJudgment.swift` (**new** optional pure) **or**
  helpers em `ConversationExecutionPhase.swift`
- `ConversationCockpitBody.swift` — ExecutingStrip action row
- `ConversationComposer.swift` / `ConversationComposerBody.swift` — strip host
- `ExecutionStateCard.swift` — primary header honesty when decision
- `EditorialTurn.swift` — only if card/strip order needs decision elevação
- `LiveNowRow.swift` / `LiveSessionSnapshot` mapping if signal exists
- `ConversationMessages.swift` — onChoose already wired; reuse
- A11y spoken ≡ decision

### Densidade alvo

- Judgment/Phase **200–800**
- Strip host fino; StateCard **≤1500** (fuse seções decision only se preciso)
- Não monólito ConversationSurface multi-domínio

### Fora de escopo

- Autônomos loop control (WAVE-030)
- Occasion pack entry (029 done)
- Presence vocabulary re-open (027 done)
- Core new DTO / invent actions
- Continuity App Group
- NL tool-write mandar-fazer
- Arena stop (já wired)
- Re-chrome pill 016

### §5 Core

`nenhum` se `state.actions` + `executionChoiceJobId` +
`resolveExecutionChoice` já publicam.  
§5 só se LiveNow precisar choice payload e snapshot **não** carrega —
documentar absence; hub = open thread only.

---

## DoD produto (≥5 checkboxes casca-prováveis)

- [ ] Quando `attentionRequired` + actions publicadas, strip mostra verbo
      **Escolher** (ou títulos das actions) — não só Parar/Redirecionar.
- [ ] Escolher no strip chama o **mesmo** `resolveExecutionChoice` path do
      StateCard (zero wire paralelo inventado).
- [ ] Primary spoken/visual **não** finge "execução ao vivo" puro quando
      attention = decision (face map honesty).
- [ ] Sem actions/jobId → silence choose theater; stop/steer só se presence
      ongoing legítimo.
- [ ] StateCard choice path permanece; strip e card **não** divergem em
      options.
- [ ] A11y spoken ≡ decision product words no strip/card.
- [ ] LiveNow: decision lead **se** signal mapeável; senão silence (no fake).
- [ ] Gates + CODEMAP "conversation decision control" (B).

## Anti-objetivos (B não deve)

- micro-onda tipografia / opacity
- fuse multi-domínio Conversation+Autônomos
- inventar options/actions no cliente
- reabrir 023/027 só para rename de face
- fuse-as-WAVE peels sem DoD de escolha
- App Group Continuity
- colapsar Shell Conversation monólito

## Plano W3 — código GOD (ordem)

1. **Extract** `ConversationDecisionJudgment` (or Phase helpers): required?
   actions? primary spoken?
2. **Fix** face map honesty for attentionRequired (paused+decision lead).
3. **Wire** strip actions: elevate choose → resolveExecutionChoice.
4. **Align** StateCard primary header with decision attention.
5. **LiveNow** lead word if snapshot allows; else absence.
6. **Delete** morto: ramos que forçam running dialect sob decision.
7. B CODEMAP.
8. Estimativa: **~6–10 arquivos · ~300–700 LOC estrutural**.

## Proof / device

1. Run com choice actions reais → strip mostra Escolher/options.
2. Tap option → job resume path; UI quiet residual sem option fantasma.
3. Run paused sem actions → sem theater Escolher.
4. attentionRequired a11y fala "decisão necessária", não só "ao vivo".
5. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Conversa explore:** #1 residual max conversa pós-027/029 =
decision-control no strip (StateCard buried; face→running lie).  
**Autônomos explore:** 030 owns loop veto — **não absorver**.  
**Home/Workspace:** workspace-live-thread-judgment = runner-up high.  
Este Δ **max** no eixo conversa: gêmeo de 026 "CTA quando pede você".

### Runner-ups (não esta onda)

1. `workspace-live-thread-judgment-instrument` — threadId live rank.
2. `self-construction-retroactive-veto-instrument` — revertCycle wire.
3. `home-ops-attention-judgment` — OPERAÇÃO mute residual.
