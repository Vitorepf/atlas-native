# WAVE-037 — autonomos-fleet-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-037-autonomos-fleet-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AutonomosModel` already hydrates **`fleet`** + **`fleetHistory`** on
  `loadSelectedDetails` — casca **never renders** them (only snapshot
  writer peeks delivery/health).
- Operator cannot judge **who is alive / authorized / desired** in the
  governed fleet without leaving the app or inventing counts.
- WAVE-036 closed task-health/incident. Residual **global fleet organ**
  (agents, spending accounts, alive) is still dark.
- Anti-objetivo: **not** resurrect onda-1 monólito fleet map — thin
  judgment instrument only (alive-first list + summary).

## Patamar

| Antes | Depois |
|---|---|
| fleet dead in UI | Judgment + thin fleet strip/surface |
| activeCount unused | Capsule honesty from published counts |
| No agent attention | Alive → unauthorized → quiet order |
| Pack silence | Pack fleet facts/absences |
| Operator blind to workers | **5s fleet judgment** on Autônomos catalog |

Δ = soberania de **frota governada** — ver quem está vivo sem monólito.

---

## Arquitetura

### Princípios

- Casca only; `AtlasAutonomosFleetResponse` fields only.
- Honesty: nil fleet → silence (no invent agents).
- Alive-first rank; authorized false elevates attention after alive.
- Thin strip on **catalog** face (not new tab/domain).
- Optional history tail (last N events) — silence if empty.
- Density: Judgment pure; surface ≤600; no multi-domínio.

### Fluxo

```
loadSelectedDetails → fleet
  → FleetJudgment.rank(agents) / summary
  → catalogFace strip above list
  → pack facts
```

### Módulos

| Nome | Papel |
|---|---|
| `AutonomosFleetJudgment` | rank · face · pack · spoken |
| `AutonomosFleetStrip` | thin catalog chrome |
| MapShell catalogFace | embed |

### Arquivos

- `AutonomosFleetJudgment.swift` (**new**)
- `AutonomosFleetStrip.swift` (**new**)
- `AutonomosMapShell.swift` — catalog embed
- `AutonomosAskContext` — pack fleet
- CODEMAP

### Densidade

Judgment 200–800 · Strip thin · no View >600

### Fora de escopo

- Full fleet map / govern set/unset UI invent  
- Core writes for fleet  
- New tab  
- Continuity App Group  
- Arena fleet (already WAVE-021)

### §5

`nenhum`.

---

## DoD (≥5)

- [ ] Catalog shows fleet strip when fleet published.
- [ ] Agents ranked: alive first, then unauthorized/desired issues.
- [ ] Nil fleet → strip absent (silence).
- [ ] Summary uses activeCount / accounts without invent.
- [ ] Pack includes fleet facts/absences.
- [ ] Spoken a11y ≡ product words.
- [ ] Gates + CODEMAP fleet judgment.

## Anti-objetivos

- monólito fleet map  
- invent agents/counts  
- micro tipografia  
- Core  
- micro-WAVE  
- multi-domínio fuse

## Plano W3

1. Judgment  
2. Strip  
3. MapShell embed  
4. Pack + CODEMAP  
5. ~5–7 files · 250–450 LOC

## Proof / device

1. Fleet with alive agents → strip shows alive-first.  
2. Nil fleet → no strip.  
3. Unauthorized alive agent elevates attention.  
4. DEVICE_PENDING.

## Council

After 036 health, global fleet agents still dark — high residual casca-only.

## §WAVE self-check

1. Patamar sim  
2. DoD≥5 sim  
3. Casca sim  
4. Design≥120 sim  
5. ≥5 files sim  
6. Densidade sim  
