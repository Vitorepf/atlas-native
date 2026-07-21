# WAVE-091 — composer-toolbar-chrome-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-091-composer-toolbar-chrome-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia · residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-046/076/081/086 own send · effort · sheets · draft strip.
  O **chrome do toolbar** (attach · options menu · mode label · workspace
  label · attach hint) ainda é dialeto string em `ComposerToolbarChrome`
  (`"adicionar anexo"`, `"modo, \(mode)"`, `"workspace, …"`).
- Send/effort already Judgment; toolbar chrome does not publish
  `toolbar_chrome_face` or spoken family exclusivity.
- Residual pós-draft-086 / effort sheets: first paint of composer row chrome.

## Patamar

| Antes | Depois |
|---|---|
| Attach/options strings | **ComposerToolbarJudgment** spoken |
| Mode/workspace local | Judgment labels |
| No pack chrome facts | pack toolbar facts optional |
| Mix with send face | Send stays 046; chrome separate |

Δ = **soberania do chrome do composer row** — attach/options/mode/ws
falam uma língua.

---

## Arquitetura

### Princípios

- Casca only. mode/workspace/effort already published on model.
- WAVE-046 pétreo: send face exclusive for gold CTA.
- WAVE-076 effort exclusive for effort chip/sheet.
- This organ: attach · options · mode · workspace spoken only.
- Zero Core.

### Fluxo

```
mode + workspaceName + effort + sendFace
  → ComposerToolbarJudgment
       spokenAttach · spokenOptions · spokenMode · spokenWorkspace
       optional chrome pack facts
  → ComposerToolbarChrome wire
```

### Tipos

| Nome | Papel |
|---|---|
| `ComposerToolbarJudgment` | attach/options/mode/ws spoken · pack |
| ComposerToolbarChrome | wire |
| CODEMAP | |

### Arquivos

- `ComposerToolbarJudgment.swift` (**new**)
- `ComposerToolbarChrome.swift`
- `ComposerToolbar.swift` (thin if needed)
- CODEMAP
- design/compress

### Densidade

Judgment 100–250 · Chrome thinner

### Fora de escopo

- Send CTA redesign  
- Draft strip (086)  
- Sheet bodies  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] spokenAttach + hint from Judgment.
- [ ] spokenOptions + hint (compose with effort options hint).
- [ ] spokenMode(mode) honesty.
- [ ] spokenWorkspace(name) honesty (Atlas default when nil).
- [ ] Optional pack toolbar facts (mode/workspace published).
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar mode/workspace  
- fundir send monólito  
- tipografia  

## Plano W3

1. Judgment spoken + pack.  
2. Wire ToolbarChrome.  
3. CODEMAP.  
4. ~5 files · ~150–300 LOC.

## Proof

1. Attach VO label ≡ Judgment.  
2. Mode sheet open path spoken mode name.  
3. Workspace nil → “Atlas”.  
4. DEVICE_PENDING.

## Council

Residual after draft-086 toolbar row. Runner-up: LiveTimelineA11y delete (idle).

---

## Spoken product (PT)

| Key | Spoken |
|---|---|
| attach | adicionar anexo |
| attachHint | abre foto, arquivo ou colar |
| options | opções da conversa |
| mode | modo, {mode} |
| workspace | workspace, {name\|Atlas} |

## Critérios de rejeição

Se B só mover 4 strings sem Judgment file + CODEMAP → fail.  
Se reabrir send face product words → fail.

---

*End WAVE-091 design.*
