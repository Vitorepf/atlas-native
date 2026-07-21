# WAVE-086 — composer-draft-attachment-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-086-composer-draft-attachment-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia · residual A runner-up)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-046 owns **send readiness** (`ComposerSendFace` ready/blocked/queue).
  O **órgão editorial dos anexos** (strip face · thumb state · upload
  percent spoken · strip silence) ainda é dialeto em `DraftStrip` /
  `DraftThumbA11y*` / `AttachmentStrip` (percent label, isVisible).
- Rank failed-first vive em SendJudgment (correto para CTA), mas strip
  spoken e thumb state parts **não** publicam `draft_strip_face` /
  `draft_thumb_face` product words.
- Sem face exclusiva: `silence | drafts(N) | uploading | failed_present`.
- Pack do composer não declara honestidade de anexos (só send face).
- Residual pós-046/076/081: attachment organ still View-local.

## Patamar

| Antes | Depois |
|---|---|
| DraftStripA11y + DraftThumbA11y soup | **ComposerDraftJudgment** faces |
| Upload % spoken local | Judgment spoken upload |
| isVisible bool dialeto | strip face silence vs content |
| Rank only for CTA | rank + strip pack shared |
| ≤5s anexo dialeto | Uma língua draft across strip/thumb |

Δ = **soberania editorial dos anexos no composer** — strip fala o estado
real dos drafts, não um contador genérico.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `LocalDraft` / `UploadProgress` já publicados no model.
- **Honesty:** never invent draft count; silence when no drafts and no %.
- **WAVE-046 pétreo:** send face stays exclusive for CTA gold; this organ
  is **attachment strip/thumb** only — may share rank helpers.
- Pack never on pill face (016).
- Zero Core / zero ConversationModel logic change.

### Fluxo / layout alvo

```
drafts[] + uploadPercent?
  → ComposerDraftJudgment.stripFace
       silence | drafts(n) | uploading | failed_present
  → rankDrafts (failed-first · shared with Send)
  → thumbFace(state) pronto|subindo|falhou
  → spoken strip / thumb / upload
  → DraftStrip · DraftThumb · AttachmentStrip peels
  → optional pack draft_strip_face
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ComposerDraftJudgment` | strip face · thumb face · rank · spoken · pack |
| DraftStrip / DraftThumb | wire |
| AttachmentStrip (ToolbarChrome) | upload + visibility |
| ComposerSendJudgment | call shared rank (optional thin re-export) |
| CODEMAP (B) | |

### Arquivos prováveis

- `ComposerDraftJudgment.swift` (**new**)
- `DraftStrip.swift`
- `DraftThumb.swift`
- `ComposerToolbarChrome.swift` (AttachmentStrip)
- `ComposerSendJudgment.swift` — rank → Draft judgment
- CODEMAP (B)

### Densidade

- Judgment **150–400**
- Peels thin

### Fora de escopo

- Core upload engine  
- New attachment kinds  
- Free-write pill  
- Send CTA redesign (046 closed)  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Exclusive strip_face product words + spoken.
- [ ] Thumb face pronto/subindo/falhou from Judgment.
- [ ] Rank failed-first owned by Draft judgment; Send reuses.
- [ ] Upload percent spoken from Judgment (honesty 0…100).
- [ ] Strip silence when no drafts and no upload %.
- [ ] Optional pack draft_strip_face + counts.
- [ ] Delete DraftStripA11y / DraftThumbA11y* forward soup → Judgment.
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar anexos  
- fundir send+draft monólito  
- reabrir 046 send face product words  
- tipografia  

## Plano W3

1. Judgment faces + rank + spoken + pack.  
2. Wire DraftStrip / DraftThumb / AttachmentStrip.  
3. SendJudgment rank → Draft.  
4. Delete A11y soup.  
5. CODEMAP (B).  
6. Estimativa: **~5–7 files · ~250–450 LOC**.

## Proof / device

1. Add image → strip face drafts(N), thumb pronto.  
2. During upload → strip uploading / thumb subindo; spoken %.  
3. Failed draft → failed_present + rank first; remove works.  
4. Empty strip → silence (no strip chrome).  
5. DEVICE_PENDING se passcode.

## Council

**Conversa explore:** #1 residual after empty-084 / send-046.  
**Código worktrees** runner-up.  
**Autônomos can_do** runner-up.

### Runner-ups

1. `codigo-worktrees-rank-judgment`  
2. `autonomos-can-do-pack-honesty`  
3. `search-result-row-judgment`  

---

*End WAVE-086 design.*
