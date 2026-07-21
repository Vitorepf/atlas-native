# WAVE-084 — conversation-empty-editorial-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-084-conversation-empty-editorial-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-072 owns messages **surface** faces (`load_fail | empty | messages`).
  O **órgão editorial do empty** (prompt quote · suggestion chips · spoken
  prompt/suggestion · default catalog) ainda é dialeto em
  `ConversationEmptyStates` + `EmptyConversationA11y` + fallback
  `HomeAskContext.emptySuggestions`.
- Multi-surface partida (Home / Workspace / Occasion / Arena / Code /
  Autônomos) passa overrides, mas **não há face/pack exclusivo**:
  `empty_face: default_prompt | custom_prompt | suggestions(N) | silence`.
- WAVE-002 law (invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts) só é
  honesta se o empty organ **julga** a ocasião — hoje o View escolhe
  defaults sem Judgment.
- Residual pós-072/078 (workspace empty editorial): **conversation empty
  partida** still View-local — first paint of a thread.

## Patamar

| Antes | Depois |
|---|---|
| EmptyConversationA11y soup | **ConversationEmptyJudgment** faces |
| Fallback Home suggestions always | face custom vs default vs none |
| Spoken local | Judgment spoken prompt/chips |
| Pack hosts override cego | pack empty_face + suggestion count |
| ≤5s partida dialeto | Uma língua empty across hosts |

Δ = **soberania da partida vazia** — o empty fala a ocasião, não um
catálogo genérico mentiroso.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `emptyPrompt` / `emptySuggestions` já nos hosts.
- **Honesty:** never invent suggestions; custom empty list → face custom;
  nil/empty → silence or default **only** when host is Home partida.
- **WAVE-002 law:** where empty UI exists, invite ≡ prompt ≡ suggestions
  ≡ turnFacts same occasion (hosts already; Judgment validates face).
- **WAVE-072 pétreo:** messages surface face stays; this is empty
  **editorial** organ inside empty branch.
- **WAVE-078** workspace empty is sibling; don't re-open workspace surface.
- Pack never on pill face (016).

### Fluxo / layout alvo

```
emptyPrompt? + emptySuggestions? + hostOccasion
  → ConversationEmptyJudgment.face
       silence | defaultHome | customPrompt | suggestions(n)
  → spoken prompt / chip labels
  → ConversationEmptyStates peels
  → optional pack fact empty_face for host AskContext
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ConversationEmptyJudgment` | face · spoken · chip a11y · pack |
| ConversationEmptyStates | wire |
| Hosts | only if default fallback moves |

### Arquivos prováveis

- `ConversationEmptyJudgment.swift` (**new**)
- `ConversationEmptyStates.swift`
- `HomeAskContext.swift` — default suggestions only via Judgment
- `ConversationSurface.swift` / View — thin if needed
- `ConversationOccasionPack.swift` — optional empty face fact
- CODEMAP (B)

### Densidade

- Judgment **150–400**
- EmptyStates thin

### Fora de escopo

- Core invent suggestions  
- Rewrite 072 messages list  
- Presence / decision / steer closed organs  
- Free-write pill intention (Cursor-port blocked)  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Exclusive empty_face product words + spoken.
- [ ] Custom prompt/suggestions from host → not overwritten by Home default.
- [ ] Home partida default suggestions only when host is home occasion.
- [ ] Chip a11y from Judgment (index/total honesty).
- [ ] Optional pack empty_face fact.
- [ ] WAVE-072 empty surface branch consumes editorial Judgment.
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar chips  
- tipografia  
- fuse empty+messages monólito  
- reabrir 029 occasion pack wholesale  

## Plano W3

1. Judgment faces from prompt/suggestions/host.  
2. Wire EmptyStates.  
3. Constrain Home fallback.  
4. Optional pack.  
5. CODEMAP (B).  
6. Estimativa: **~5–8 files · ~250–450 LOC**.

## Proof / device

1. Home new → default suggestions face.  
2. Autônomos/Code ask sheet custom invite → custom face, not Home chips.  
3. Empty suggestions list → silence chips.  
4. Spoken prompt ≡ visual.  
5. DEVICE_PENDING se passcode.

## Council

**Conversa explore:** #1 high residual empty editorial after 072.  
**Arena 082/083** max siblings open/racing.  
**Draft strip** = next runner-up.

### Runner-ups

1. `composer-draft-attachment-judgment`  
2. `codigo-worktrees-rank-judgment`  
3. `autonomos-can-do-pack-honesty`  

---

*End WAVE-084 design.*
