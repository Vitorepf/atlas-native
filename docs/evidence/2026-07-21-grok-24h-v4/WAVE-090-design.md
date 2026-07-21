# WAVE-090 — autonomos-list-row-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-090-autonomos-list-row-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-026 ranks units (awaiting → live → quiet) via DecisionJudgment.
  O **órgão editorial da lista** (empty face · row face · spoken empty/row ·
  trailing badge honesty) ainda é dialeto privado em `AutonomosListView`
  (`spoken`, empty accessibility string, trailing “vivo”).
- WAVE-088 can_do pack honesty exists; list surface pack does not declare
  `autonomos_list_face` / row product words.
- Residual pós-can_do / hub vestment: catalog index still View-local.

## Patamar

| Antes | Depois |
|---|---|
| Empty a11y string soup | **listFace empty/list(N)** |
| spoken(unit) private | Judgment spokenRow |
| Trailing “vivo” dialect | rowFace product/spoken |
| Rank only | rank + list pack |

Δ = **soberania do índice Autônomos** — lista fala empty vs rows, não
copy solto.

---

## Arquitetura

### Princípios

- Casca only. Units local catalog; awaiting IDs hydrated only.
- WAVE-026 rank stays DecisionJudgment; List judgment may re-export.
- WAVE-088 can_do stays AskContext; list pack is separate.
- Honesty: never invent awaiting; empty states say local-only + §5 create.

### Fluxo

```
units[] + awaitingUnitIDs
  → AutonomosListJudgment.listFace empty | list(n)
  → rankUnits (Decision)
  → rowFace awaiting | live | quiet
  → spoken empty / row
  → AutonomosListView wire
  → pack autonomos_list_face
```

### Arquivos

- `AutonomosListJudgment.swift` (**new**)
- `AutonomosListView.swift`
- optional AskContext catalog pack
- CODEMAP
- design/compress

### Densidade

Judgment 120–280

### Fora de escopo

- Core create Autônomo  
- Hub vestment rewrite  
- Map shell  

### §5

`nenhum` (create still pending — pack absence).

---

## DoD produto (≥5)

- [ ] listFace empty | list(N) exclusive product words.
- [ ] rowFace awaiting | live | quiet from Judgment.
- [ ] Empty + row spoken from Judgment.
- [ ] Rank via Decision (re-export); trailing badge uses rowFace.
- [ ] Pack autonomos_list_face + counts.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar awaiting  
- fundir hub monólito  
- tipografia  

## Plano W3

1. Judgment.  
2. Wire ListView.  
3. Optional catalog pack.  
4. CODEMAP.  
5. ~5 files · ~200–350 LOC.

## Proof

1. Empty catalog → empty face spoken.  
2. Awaiting unit ranks first, row face awaiting.  
3. Paused → quiet product word.  
4. DEVICE_PENDING.

## Council

Residual after can_do-088. Next runners: LiveTimeline density peels (idle).

---

## Row face map

| Condition | rowFace |
|---|---|
| id ∈ awaitingUnitIDs | awaiting |
| unit.paused | quiet |
| else | live |

Trailing: awaiting/quiet text productWord; live → accent dot + spoken “vivo”.

## Critérios de rejeição

Se B só mover `spoken` sem face/pack → fail.  
Se inventar awaiting sem Set → fail.

---

*End WAVE-090 design.*
