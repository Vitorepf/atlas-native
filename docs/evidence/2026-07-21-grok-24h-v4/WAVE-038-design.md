# WAVE-038 — autonomos-digest-moment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-038-autonomos-digest-moment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `model.digest` is hydrated on area load — **never shown** in casca.
- Destination `.moment` still empty theater (“sem feed de momentos”) while
  digest publishes **window · counts · delivered · risks · pendingDecisions**.
- Operator cannot read the scheduled Autônomos **digest window** that the
  server already provider-safes for the app.
- After fleet (037) and task health (036), residual **time-window judgment**
  (what shipped / risks / decisions in last N hours) is dark.

## Patamar

| Antes | Depois |
|---|---|
| digest dead in UI | Judgment + Digest/Moment surface |
| .moment = theater | Real digest sections |
| Hub no path to digest | Nav when digest published |
| Pack silence | Pack window/counts/risks |
| Blind to schedule window | **5–10s digest judgment** |

Δ = soberania de **janela agendada** — o que a frota entregou e o que
ainda pede julgamento no recorte.

---

## Arquitetura

### Princípios

- Casca only; `AtlasAutonomosDigestResponse` fields only.
- Honesty: nil digest → silence; empty last → quiet face.
- Pending decisions ranked by priorityScore; risks by severity.
- Destination `.moment("digest")` for list (id stable).
- No invent of cycle beyond published items.
- Thin surface; Judgment pure.

### Fluxo

```
loadSelectedDetails → digest
  → DigestJudgment.face / sections
  → Hub nav → .moment("digest")
  → surface: window · counts · delivered · risks · pending
  → pack
```

### Módulos

| Nome | Papel |
|---|---|
| `AutonomosDigestJudgment` | face · rank · pack · labels |
| `AutonomosDigestSurface` | composition |
| MapShell / Hub | wire |

### Arquivos

- `AutonomosDigestJudgment.swift` (**new**)
- `AutonomosDigestSurface.swift` (**new**)
- `AutonomosMapShell.swift` — route .moment
- `AutonomosHubView` — nav when digest present
- `AutonomosAskContext` — pack
- CODEMAP

### Densidade

Judgment 200–800 · Surface thin · Shell ≤600

### Fora de escopo

- Invent moment feed without digest  
- Core schedule write  
- New tab  
- Continuity  
- Duplicate evolution (034)

### §5

`nenhum`.

---

## DoD (≥5)

- [ ] .moment shows digest when published (window + counts).
- [ ] Sections: delivered, risks, pending decisions — only published.
- [ ] Rank pending by priorityScore; risks by severity when present.
- [ ] Nil digest → quiet absence (no create-server lie).
- [ ] Hub nav to digest when available.
- [ ] Pack digest facts/absences.
- [ ] Gates + CODEMAP digest moment.

## Anti-objetivos

- invent items  
- monólito fleet+digest fuse multi-domínio  
- micro tipografia  
- Core  
- micro-WAVE

## Plano W3

1. Judgment  
2. Surface  
3. MapShell + Hub  
4. Pack + CODEMAP  
5. ~5–8 files · 300–500 LOC

## Proof / device

1. Digest with counts → surface shows sections.  
2. Nil → silence.  
3. Pending decisions elevated by priority.  
4. DEVICE_PENDING.

## Council

Digest hydrated unused — high residual after 036/037.

## §WAVE self-check

1–6 pass (patamar, DoD≥5, casca, ≥120 lines, ≥5 files, density).  
