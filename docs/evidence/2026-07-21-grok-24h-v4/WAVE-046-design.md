# WAVE-046 — composer-send-readiness-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-046-composer-send-readiness-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- O verbo diário do produto — **enviar** — **não é julgado**.
- `ComposerToolbar.canSubmitFromDraft` = texto **OU qualquer draft**
  (`!model.drafts.isEmpty`). Drafts em `.falhou` / `.subindo`
  (`LocalDraft.State`) **ainda acendem o CTA gold** de send.
- Spoken paths separam send vs «adicionar à fila» vs diamond processing,
  mas **não** há face pura: `ready` · `blocked_failed` · `blocked_uploading`
  · `queue_only` · `executing`.
- Draft strip mostra veil de falha; o botão de send **ignora** o organ —
  **mentira de prontidão**.
- Attachment-only path depende do model inventar texto após tap; UI
  afirma ready antes do organ estar pronto.
- Chip "Fila · N" é count-only — sem head/preview judgment (secundário
  nesta onda se barato).
- Pós-031 (decision strip) e 027 (presence): residual **composer readiness**
  é o furo do próximo send, não mid-run control.

## Patamar

| Antes | Depois |
|---|---|
| Gold send com draft falho/subindo | CTA honest por **SendReadiness face** |
| Bool canSubmit soup | Judgment exclusive faces + spoken |
| Strip falha ≠ botão | Mesma língua strip ↔ send |
| Fila count-only | Optional head face se barato |
| Operador descobre no erro | ≤5s sabe send / wait / fix / queue |

Δ = **soberania do próximo ato** — o CTA nunca mente "pronto".

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only / presentation.** Julga `draftText`, `LocalDraft.State`,
  `isSending`, `liveBubble` **já no model** — **não** edita
  `ConversationModel` lógica de send (Codex seam). Helpers presentation
  em Judgment ou `ConversationModel+UI` se inevitável.
- **Honesty:** failed draft → blocked_failed (não gold); uploading →
  blocked_uploading; empty+no ready draft → silence disabled; live
  executing → queue_only / executing law already partially there.
- **Silence:** zero toast theater; disabled CTA + spoken reason.
- **WAVE-031 pétreo:** decision strip Escolher permanece; esta onda é
  send organ, não choice.
- **WAVE-006 live composer** pétreo: strip presence continua.
- Um domínio: ComposerSendJudgment — não monólito ConversationSurface.

### Fluxo / layout alvo

```
draftText + drafts[] + isSending + liveBubble?
  → ComposerSendJudgment.face
       ready | blocked_failed | blocked_uploading
       | queue_only | executing | empty
  → canSubmit = face.allowsSend
  → gold only if ready (or queue_only with text law)
  → spokenSendLabel/Hint from face
  → DraftStrip optional rank: failed first (attention)
  → optional Fila chip head preview
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ComposerSendJudgment` | face · allowsSend · spoken · optional draft rank |
| ComposerToolbar* | wire canSubmit + a11y from Judgment |
| DraftStrip / DraftThumb | optional failed-first attention |

### Arquivos prováveis

- `ComposerSendJudgment.swift` (**new** pure)
- `ComposerToolbarChrome.swift` — canSubmit + spoken
- `ComposerToolbar.swift` — thin host if needed
- `DraftStrip.swift` / `DraftThumb.swift` — attention rank optional
- `ConversationComposerBody.swift` — only if strip host needs face
- A11yID if new ids
- CODEMAP (B)

### Densidade

- Judgment **150–500**
- Toolbar chrome shrinks bool soup
- Não colapsar composer monólito multi-domínio

### Fora de escopo

- Core upload engine / ConversationModel.sendTurn business logic  
- Rich-input server contract  
- Re-open 031 decision / 027 presence  
- LiveTimeline re-rank (044 owns narrative face)  
- Queue sheet full redesign (absorb head-face only if cheap)  
- Home pill intention (blocked Cursor-port)  
- Micro tipografia  

### §5

`nenhum` — `LocalDraft.State` já publicado.

---

## DoD produto (≥5)

- [ ] Face exclusiva de readiness com product words + spoken.
- [ ] Draft `.falhou` → **não** gold send; spoken explica fix/retry.
- [ ] Draft `.subindo` → blocked_uploading; CTA não mente ready.
- [ ] Texto ready ou draft ready → send allows; empty → disabled silence.
- [ ] Executing/live law: queue_only vs executing honesty (preserve 006).
- [ ] A11y send label/hint ≡ face.
- [ ] Gates + CODEMAP "composer send readiness" (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar auto-texto de anexo na casca  
- editar lógica Core/Model de upload  
- fuse multi-domínio  
- micro-WAVE tipografia  
- reabrir decision strip  

## Plano W3

1. Extract `ComposerSendJudgment` from canSubmit soup + draft states.
2. Wire Toolbar canSubmit + spoken + gold gate.
3. Optional DraftStrip failed-first.
4. Optional Fila head face.
5. Delete bool paths mortos (rg).
6. CODEMAP (B).
7. Estimativa: **~5–8 files · ~280–500 LOC**.

## Proof / device

1. Anexar arquivo → uploading → CTA não gold "enviar".
2. Draft falhou → CTA blocked + spoken; strip shows fail.
3. Texto only → send ready.
4. Live executing + text → queue law preserved.
5. DEVICE_PENDING se passcode.

## Council

**Conversa explore:** #2 residual high = composer send readiness (home
pill intention blocked).  
**Sovereignty explore:** home-ops = WAVE-045 max; agent-lanes runner-up.  
**Código explore:** heal veto residual — onda futura.

### Runner-ups

1. `conversation-agent-lanes-judgment`  
2. `codigo-heal-veto-judgment` (undoError never rendered)  
3. `arena-live-control-judgment`  

---

*End WAVE-046 design.*
