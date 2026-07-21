# WAVE-034 — autonomos-evolution-delivered-proof-surface

**Status:** design · proposed  
**Wave:** `WAVE-034-autonomos-evolution-delivered-proof-surface`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Hub nav **"Evolução · ainda sem provas"** + `AutonomosEvolutionView`
  always copy **"Ainda sem prova publicada"** even when
  `model.delivered.delivered` has **merge-proved cycles** (banner self-
  construction already reads the same source).
- Residual after WAVE-033 (veto on receipt sheet): operator **cannot
  browse the timeline of entregas** for this area — only the latest
  merge banner. Evolution is the declared place for marcos.
- Wire hydrated: `loadSelectedDetails` fills `delivered` / `cycles`.
  Casca refuses to show them on Evolution.
- Mentira de órgão: "quando Server aceitar create" while delivered
  already publishes merge-proved ledger rows for bound areas.

## Patamar

| Antes | Depois |
|---|---|
| Evolution always empty theater | **List merge-proved + published cycles** from model |
| "ainda sem provas" with data | Exclusive faces: empty / items / unbound |
| Only latest banner | Timeline marcos + open receipt (033 veto path) |
| Pack silence on evolution | Pack subjects = top delivered titles/outcomes |

Δ = **prova de entrega** legível — operator judges what the fleet shipped.

---

## Arquitetura

### Princípios

- Casca only; `model.delivered` / `model.cycles` already loaded with area.
- Honesty: unbound area → empty + absence; empty delivered → quiet empty.
- Prefer **merge-proved first** in judgment order; non-merge cycles secondary
  if published in `cycles` without inventing merges.
- Tap merge-proved → existing SelfConstructionReceipt sheet (033 veto).
- Density: thin Evolution surface; Judgment pure.

### Fluxo

```
selectArea → delivered hydrated
  → Evolution destination
  → AutonomosEvolutionJudgment.items(delivered, cycles)
  → faces empty|items|unbound
  → row tap merge-proved → SelfConstructionReceipt
```

### Módulos

| Nome | Papel |
|---|---|
| `AutonomosEvolutionJudgment` | rank · face · product words · cycle labels |
| `AutonomosEvolutionView` | surface composition |
| MapShell | pass model + open receipt |

### Arquivos

- `AutonomosEvolutionJudgment.swift` (**new**)
- `AutonomosEvolutionView.swift` — real list
- `AutonomosMapShell.swift` — inject model / onOpenReceipt
- `AutonomosHubView` — meta "ainda sem provas" honesty if delivered
- `AutonomosAskContext` — evolution facts from delivered
- CODEMAP

### Densidade

Judgment 200–800 · View ≤600 · no multi-domínio

### Fora de escopo

- Create Autônomo server  
- Full fleet dashboard resurrection  
- Core new fields  
- Continuity App Group  
- Transfer mission full surface (runner-up)

### §5

`nenhum` for delivered list. Absence if cycles empty after bind.

---

## DoD (≥5)

- [ ] Evolution shows **published** delivered cycles when area bound + data.
- [ ] Merge-proved rows open receipt (033 path).
- [ ] Empty/unbound exclusive faces — no "create server" lie when delivered
      exists.
- [ ] Judgment ranks merge-proved first.
- [ ] Hub Evolução meta reflects real count or honesty.
- [ ] Pack evolution facts when destination .evolution.
- [ ] Gates + CODEMAP evolution proof.

## Anti-objetivos

- invent cycles  
- fuse hub+evolution monólito  
- micro tipografia  
- Core  
- micro-WAVE

## Plano W3

1. Extract Judgment  
2. Wire EvolutionView + MapShell  
3. Hub meta honesty  
4. Pack  
5. CODEMAP  
6. ~5–8 files · 250–500 LOC

## Proof / device

1. Bound area with delivered → Evolution lists marcos.  
2. Tap merge-proved → receipt + veto if canControl.  
3. Unbound → empty honesty.  
4. DEVICE_PENDING.

## Council

WAVE-030 runner-up: evolution delivered proof surface. Δ high after 033.

## §WAVE self-check

1. Patamar sim  
2. DoD≥5 sim  
3. Casca sim  
4. Design≥120 sim  
5. ≥5 files sim  
6. Densidade sim  
