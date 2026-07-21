# WAVE-036 — autonomos-task-health-incident-instrument

**Status:** design · proposed  
**Wave:** `WAVE-036-autonomos-task-health-incident-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AutonomosModel` already loads **`taskHealth`** and **`digest`** on
  `loadSelectedDetails` — but **casca never renders them** (only
  `AtlasNativeSnapshotWriter` peeks taskHealth).
- Destination `.incident` / `.moment` still show **"Ainda no escopo local /
  create no servidor"** theater while server already publishes
  `incidents.present` + `flags` + `operating.recommendedAction` + queue
  pressure.
- Hub vestment `incidentPresent: false` is **hard-coded** in MapShell —
  so even when task health says incident, hub never elevates "Precisa de
  você".
- A11y IDs `autonomos-task-health-quiet` / `incident` already reserved —
  organ promised, body missing.
- After 026–035 (decide / control / evolution / transfer / veto), residual
  **fleet health attention** is the hole: operator cannot judge muscle
  health or open the incident surface.

## Patamar

| Antes | Depois |
|---|---|
| taskHealth dead in UI | Judgment face + incident surface |
| incidentPresent always false | Driven by `taskHealth.incidents.present` |
| .incident = theater | Real flags + recommended action + counts |
| Hub silent on incident | Nav / vestment honesty when present |
| Pack no health | Pack task health facts/absences |

Δ = **atenção de saúde da frota** — julgar quiet vs incident em ≤5s.

---

## Arquitetura

### Princípios

- Casca only; fields already on `AtlasAutonomosTaskHealthResponse`.
- Honesty: nil taskHealth → unbound/empty face, not invent flags.
- Digest optional secondary (window counts) — don't invent items.
- Never invent incident text beyond published flags/action/pressure.
- Density: Judgment pure; thin Incident surface.

### Fluxo

```
loadSelectedDetails → taskHealth
  → Judgment.face / incidentPresent
  → Hub vestment.resolve(incidentPresent:)
  → .incident destination surface
  → pack facts
```

### Módulos

| Nome | Papel |
|---|---|
| `AutonomosTaskHealthJudgment` | face · present · pack · spoken |
| `AutonomosIncidentSurface` | composition 1 domínio |
| MapShell / Hub | wire incidentPresent + route |

### Arquivos

- `AutonomosTaskHealthJudgment.swift` (**new**)
- `AutonomosIncidentSurface.swift` (**new**)
- `AutonomosMapShell.swift` — incidentPresent + route
- `AutonomosHubView` — optional incident nav when present
- `AutonomosAskContext` — pack health
- CODEMAP

### Densidade

Judgment 200–800 · Surface thin · Shell ≤600

### Fora de escopo

- Fleet map monólito resurrection  
- Core new incident DTO  
- Moment feed invent  
- Continuity App Group  
- Arena

### §5

`nenhum`. taskHealth already provider-safe.

---

## DoD (≥5)

- [ ] `incidentPresent` from taskHealth (not hard-coded false).
- [ ] `.incident` lists published flags + recommendedAction + pressure.
- [ ] Exclusive faces: unbound / quiet-healthy / incident / empty-load.
- [ ] Hub offers path to incident when present (nav or primary adjacency).
- [ ] Pack includes healthy/incidents/pressure facts; absences if nil.
- [ ] A11y ids quiet/incident used.
- [ ] Gates + CODEMAP task health.

## Anti-objetivos

- invent flags  
- micro tipografia  
- fuse multi-domínio  
- Core  
- micro-WAVE  
- full fleet dashboard

## Plano W3

1. Judgment  
2. Incident surface  
3. MapShell vestment + route  
4. Hub nav  
5. Pack + CODEMAP  
6. ~6–8 files · 300–500 LOC

## Proof / device

1. Bound area with incident.present → hub elevates / incident surface.  
2. Healthy → quiet face, no alarm chrome.  
3. Nil taskHealth → absence honesty.  
4. DEVICE_PENDING.

## Council

Autônomos residual after 030–035: health/incident organ published but dark.

## §WAVE self-check

1. Patamar sim  
2. DoD≥5 sim  
3. Casca sim  
4. Design≥120 sim  
5. ≥5 files sim  
6. Densidade sim  
