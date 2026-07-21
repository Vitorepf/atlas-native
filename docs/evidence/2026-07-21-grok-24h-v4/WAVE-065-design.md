# WAVE-065 — autonomos-multi-area-bind-chooser-instrument

**Status:** design · proposed  
**Wave:** `WAVE-065-autonomos-multi-area-bind-chooser-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-030 ligou **controle do loop** + `bindAreaID`, mas a policy é:
  - **0** registered → nil  
  - **1** registered → auto-select  
  - **N>1** registered → **nil forever** (unless `defaultArea` magic)
- Com N áreas, `selectedArea` fica nil → `loadSelectedDetails` /
  live / backlog / fleet / decide / control / evolution / health /
  transfer **não hidratam** → órgãos 026–038 viram **quiet theater**
  mesmo com frota real no servidor.
- WAVE-030 design **prometeu** thin chooser multi — **nunca shipped**.
- Pack/Ask fala unbound; hub face `.unbound`; operador não consegue
  **escolher o mundo** da frota em ≤10s.
- Isto é **soberania de bind** — sem ela, toda a vertical Autônomos
  multi-tenant é mentira de silêncio.

## Patamar

| Antes | Depois |
|---|---|
| N areas → unbound forever | **Chooser** thin → `selectArea` → hydrate |
| Organs dark when multi | Organs live after bind |
| Pack only absence multi | Pack: areas count · selected · absence until chosen |
| Operador sem porta | ≤10s escolhe área registered e age |

Δ = **soberania multi-área** — desbloqueia a frota real quando há >1 area.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `listAutonomosAreas` + `selectArea` + `areas[].registered`
  já no model.
- **Honesty:** unregistered areas não entram como controláveis; zero invent
  de area. Empty registered → silence + absence (já 030).
- **Thin chooser:** lista de areas registered (nome/id/focus se
  publicados) — **não** ressuscitar monólito AreaPicker onda-1.
- **Persist last selection** optional via existing defaultArea param or
  lightweight UserDefaults presentation-only if already pattern; never Core.
- **WAVE-030/026 pétreos:** control/decision organs unchanged once bound.
- Pack law 020: surface autonomos · selected area subject · absences multi.
- Um domínio: area bind organ.

### Fluxo / layout alvo

```
load areas
  → AutonomosRunControlJudgment.bindPolicy:
       0 → unbound silence
       1 → selectArea(auto)
       N → face .needsBind + chooser surface
  → operator picks registered area
  → model.selectArea(id) → loadSelectedDetails
  → existing hub vestment / control / decision light up
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| Extend `AutonomosRunControlJudgment` **or** `AutonomosAreaBindJudgment` | policy 0/1/N · face needsBind · pack |
| Thin chooser view | list registered → onSelect |
| MapShell | present chooser when N unbound |

### Arquivos prováveis

- `AutonomosAreaBindJudgment.swift` (**new**) **or** grow RunControlJudgment
- `AutonomosAreaBindChooser.swift` (**new** thin surface)
- `AutonomosMapShell.swift` — present chooser / bind hook
- `AutonomosHubView.swift` — CTA "Escolher área" if needsBind
- `AutonomosAskContext.swift` — multi-area pack honesty
- `AutonomosListView.swift` — only if catalog shows bind state
- A11yIDs
- CODEMAP (B)

### Densidade

- Judgment **150–400**
- Chooser **≤300** thin
- MapShell ≤600

### Fora de escopo

- Create area no servidor  
- Fleet monólito onda-1 resurrect  
- Core unit↔area DTO (§5 só se product exigir binding named unit)  
- Continuity App Group  
- Micro tipografia  
- Reabrir decision/control organs  

### §5

`nenhum` se areas list + selectArea bastam.  
§5 só se unit local precisa map 1:1 area no wire — absence + manual
chooser ok.

---

## DoD produto (≥5)

- [ ] N registered areas → UI **chooser** (não unbound forever).
- [ ] Pick → `selectArea` → live/backlog hydrate (organs 026–038 usable).
- [ ] 1 registered → still auto-bind (030 law).
- [ ] 0 registered → silence + pack absence (no theater).
- [ ] Pack: selected area · count · needsBind absence honesty.
- [ ] Spoken a11y chooser ≡ face needsBind.
- [ ] Gates + CODEMAP "autonomos area bind" (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar areas  
- monólito picker forest  
- tipografia  
- fuse multi-domínio  
- Core new bind field sem §5  

## Plano W3

1. Judgment bind policy faces (0/1/N).  
2. Thin chooser surface.  
3. Wire MapShell/Hub CTA.  
4. Pack honesty.  
5. rg: multi no longer stuck unbound when areas>1.  
6. CODEMAP (B).  
7. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. Fixture/server com 2+ registered areas → chooser appears.  
2. Select A → hub live/control/decision hydrate for A.  
3. Switch B (if UI allows) → projection refresh.  
4. 1 area → auto, no chooser noise.  
5. DEVICE_PENDING se passcode.

## Council

**Autônomos/Código explore:** #1 residual max frota = multi-area bind
gap (030 promise unpaid).  
**Home explore:** LiveNow triple dialect = WAVE-064.  
**Arena:** now-phase / can_do pack = runner-ups.

### Runner-ups

1. `arena-now-phase-judgment`  
2. `codigo-radar-screen-judgment`  
3. `arena-live-can-do-pack-honesty`  
4. `autonomos-control-receipt-tone`  

---

*End WAVE-065 design.*
