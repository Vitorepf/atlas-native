# WAVE-081 — composer-sheet-mode-workspace-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-081-composer-sheet-mode-workspace-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after effort 076)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ComposerSheetA11y` owns mode labels (geral/operacional/autônomos/
  programação) and workspace sheet empty/list spoken **without pure
  Judgment** for the composer options-sheet organ.
- WAVE-076 closed effort face; residual **mode + workspace sheets**
  still dialect soup (local footnote, mode table, workspace counts).
- Pack cannot reuse `composer_mode_face: geral|…` or
  `composer_workspace_sheet_face: empty|list`.

## Patamar

| Antes | Depois |
|---|---|
| Mode tuple soup | Exclusive mode face |
| Workspace empty/list local | Exclusive workspace-sheet face |
| No pack | Pack mode + workspace sheet |

Δ = **soberania das folhas de opções do composer** — modo e pasta do
próximo envio com uma língua.

---

## Arquitetura

### Princípios

- Casca only; modes table + workspaces published.
- Honesty: mode is local label (modeFootnote already says not routing);
  workspace only from loaded conversations.
- One domain: composer options sheets (not send/effort).

### Fluxo

```
mode key + workspaces + current
  → ComposerSheetJudgment.modeFace / workspaceFace / spoken / pack
  → ModeSheet · WorkspaceSheet · ComposerSheetA11y peels
```

### Arquivos (≥5)

- `ComposerSheetJudgment.swift` (**new**)
- `ConversationChrome.swift` (ComposerSheetA11y)
- `ConversationChromeSheetsHost.swift`
- CODEMAP · design · compress

### Densidade

Judgment 150–320.

### Fora de escopo

- Core routing of mode  
- Effort rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Mode face: geral · operacional · autonomos · programacao · unknown.
2. Workspace sheet face: empty · list(N).
3. modeLabel / workspaceLabel / empty / hints from Judgment.
4. modes table single source on Judgment.
5. Pack mode + workspace sheet faces.
6. accessibilityValue productWord on ModeSheet + WorkspaceSheet.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent workspaces  
- claim mode changes payload  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire A11y + sheets  
3. CODEMAP · compress  

Estimativa: **5–7 files · 220–380 LOC**.

## Proof

1. mode operacional → face operacional spoken.  
2. empty workspaces → empty face.  
3. list with N → list face.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Mode/workspace residual after effort. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-081 design.*
