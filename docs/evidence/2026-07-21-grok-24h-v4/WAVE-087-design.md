# WAVE-087 — codigo-worktrees-rank-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-087-codigo-worktrees-rank-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · residual after 086 · A runner-up)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Grafo C22 publica `worktrees[]` (pathLabel · branch · head · state).
  A **faixa WORKTREES** em `AtlasCodeGraphChrome` renderiza wire order e
  spoken local (`worktreeSpokenLabel`) sem face/pack exclusivo.
- Pack em GraphJudgment lista worktrees crus — sem `worktree_face` /
  rank dirty-first / silence when empty.
- Residual pós-028 filter/pack e peels de grafo: worktrees still View dialect.

## Patamar

| Antes | Depois |
|---|---|
| Wire order chips | **rank** dirty/active first |
| Spoken local private | Judgment spoken |
| Pack count only | pack face + ranked anchors |
| Empty section possible | face silence vs list(N) |

Δ = **soberania dos worktrees no grafo** — chip fala estado, rank honesto.

---

## Arquitetura

### Princípios

- Casca only. `AtlasCodeWorktree` already published.
- Honesty: never invent branch/state; silence when empty list.
- Don't re-open graph filter Judgment wholesale.
- Zero Core.

### Fluxo

```
worktrees[]
  → AtlasCodeWorktreeJudgment.sectionFace silence | list(n)
  → rank (dirty/active first · path stable)
  → chipFace from state string honesty
  → spoken chip / section
  → GraphChrome wire
  → pack worktree_face + anchors
```

### Tipos

| Nome | Papel |
|---|---|
| `AtlasCodeWorktreeJudgment` | section face · rank · chip spoken · pack |
| GraphChrome | wire |
| GraphJudgment | packSliceFacts → Worktree pack |
| CODEMAP | |

### Arquivos

- `AtlasCodeWorktreeJudgment.swift` (**new**)
- `AtlasCodeGraphChrome.swift`
- `AtlasCodeGraphJudgment.swift`
- `AtlasCodeSurfaceGraph.swift` (thin if needed)
- CODEMAP

### Densidade

Judgment 120–300 · Chrome thinner

### Fora de escopo

- Core worktree API  
- Filter chips rework  
- Heal/week organs  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] section_face silence | list(N) exclusive product words.
- [ ] Rank dirty/active-first (state non-empty / not clean first).
- [ ] Chip spoken from Judgment (path · branch · state honesty).
- [ ] Pack worktree_face + ranked anchors (not only raw dump).
- [ ] Empty → silence (no false worktree section chrome claim).
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar worktrees  
- fundir filter monólito  
- tipografia  

## Plano W3

1. Judgment face/rank/spoken/pack.  
2. Wire Chrome section.  
3. GraphJudgment pack uses Worktree pack.  
4. CODEMAP.  
5. ~5 files · ~200–350 LOC.

## Proof

1. Repo with dirty worktree → ranks first, spoken state.  
2. Empty worktrees → silence pack absence.  
3. DEVICE_PENDING.

## Council

Runner-up after draft-086. Next: autonomos-can-do-pack-honesty.

---

*End WAVE-087 design.*
