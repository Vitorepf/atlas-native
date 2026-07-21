# WAVE-097 — workspace-picker-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-097-workspace-picker-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasWorkspacePickerSheet` ainda **julga e ordena na View**:
  dedupe slug, sort lastCommitAt, filter query, load/fail/empty states,
  spoken “sem repositório” / row / fail copy.
- Sem face/pack exclusivo: loading | failed | empty | list(N) | miss.
- Residual pós-composer sheet judgments — picker é porta de workspace
  no composer e em outras shells; dialeto local impede honesty pack.

## Patamar

| Antes | Depois |
|---|---|
| Sort/filter na View | **WorkspacePickerJudgment** rank/filter |
| Load/fail copy local | face + spoken |
| Row a11y string soup | spokenRow |
| Sem pack | pack picker_face |

Δ = **soberania do picker de workspace** — lista e empty falam a face.

---

## Arquitetura

### Princípios

- Casca only. `AtlasCodeRepoRef` / workspace model published.
- Honesty: never invent repos; miss when query filters to zero.
- Don't re-open Radar multi-repo monólito.
- Zero Core.

### Fluxo

```
workspace.folders/loose/recents + query + phase
  → WorkspacePickerJudgment
       face loading|failed|empty|list(n)|miss
       rankRepos · filter query
       spoken noRepo · row · load · fail
  → AtlasWorkspacePickerSheet wire
  → optional pack
```

### Arquivos

- `WorkspacePickerJudgment.swift` (**new**)
- `AtlasWorkspacePickerSheet.swift`
- CODEMAP
- design/compress

### Densidade

Judgment 150–350 · Sheet thin

### Fora de escopo

- Core Mac workspace scan  
- Repo picker Código graph (sibling) fuse unless free  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] face loading|failed|empty|list(N)|miss exclusive product words.
- [ ] rank lastCommit-first + name stable; filter query pure.
- [ ] spoken noRepo · row · load · fail from Judgment.
- [ ] Sheet wires Judgment only for list math/a11y.
- [ ] Pack picker_face + counts.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar repos  
- tipografia  
- fuse with Radar host  

## Plano W3

1. Judgment face/rank/filter/spoken/pack.  
2. Wire picker sheet.  
3. CODEMAP.  
4. ~5 files · ~250–400 LOC.

## Proof

1. Loading face spoken.  
2. Fail → retry spoken.  
3. Query miss → miss face.  
4. Row spoken folder+name.  
5. DEVICE_PENDING.

## Council

Residual after hub-096 + composer sheets closed.

---

## Faces

| Face | Quando |
|---|---|
| loading | idle/loading phase |
| failed | failed phase |
| empty | ready, zero repos, no query |
| list(N) | N repos after filter |
| miss | query non-empty, zero hits |

## Critérios de rejeição

Se B só mover strings sem rank/face/pack → fail.

---

*End WAVE-097 design.*
