# WAVE-054 — codigo-commit-row-face-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-054-codigo-commit-row-face-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeCommitRowBody` (~584 LOC) owns **branch meta color**, tip-branch
  parse, and state-adjacent chrome without a pure **row face Judgment**.
- Graph list already ranks via `AtlasCodeGraphJudgment` (028), but the **row
  organ** still has dialect for dimmed ("fora da resposta") vs node state
  without exclusive face product words for pack/a11y hosts.
- Tip-branch parsing is pure and buried in View extension — agent friction.
- Residual after graph judgment + heal veto: **commit row face** is the
  line-item organ still View-owned.

## Patamar

| Antes | Depois |
|---|---|
| Meta color switch in View | Judgment.branchMetaColor |
| tipBranch in View | Judgment pure |
| Dim only opacity | Face includes dimmed |
| productWord only graph | Row face: state + dim |

Δ = **soberania da linha do commit** — fora/curado/main/história/dim.

---

## Arquitetura

### Princípios

- Casca only; `AtlasCodeNodeState` + node refs already.
- Align productWord with `AtlasCodeGraphJudgment.productWord(for:)` when not
  dimmed; dimmed elevates exclusive `dimmed` face.
- tipBranch pure static — no invent branch names.
- One domain: código commit row.

### Fluxo

```
node + state + isDimmed + trunk
  → CommitRowJudgment.face / branchMetaColor / tipBranch / displayBranch
  → AtlasCodeCommitRow peels
```

### Arquivos (≥5)

- `AtlasCodeCommitRowJudgment.swift` (**new**)
- `AtlasCodeCommitRowBody.swift`
- `AtlasCodeCommitRow.swift` (optional wire color)
- CODEMAP
- design + compress

### Densidade

Judgment 150–400 · Body ↓ dialect.

### Fora de escopo

- Graph rank rewrite (028)  
- Spine canvas rewrite  
- Core  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: dimmed · violating · healed · onMain · history.
2. productWord stable for pack/a11y.
3. branchMetaColor from Judgment.
4. tipBranch + displayBranch pure Judgment.
5. Row peels call Judgment (no parallel tip parse).
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent branch  
- re-rank graph list  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire row body  
3. CODEMAP · compress  

Estimativa: **5–6 files · 220–360 LOC**.

## Proof

1. Violating → alert meta color.  
2. Dimmed → face dimmed productWord.  
3. tip branch from refs excluding trunk.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Commit row residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-054 design.*
