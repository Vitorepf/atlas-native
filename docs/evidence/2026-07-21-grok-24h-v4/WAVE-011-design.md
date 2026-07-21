# WAVE-011 — radar-fleet-glance

**Status:** design · proposed  
**Wave:** `WAVE-011-radar-fleet-glance`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **med–high**  
**Rank:** 6  

---

## Problema

O Radar é a **folha de julgamento da frota** no Mac do operador — aberta **antes**
de qualquer repo. WAVE-001+002 entregaram pílula (`AgenticAskDock`), pack
presentation-only (`AtlasCodeRadarAskContext` com issuesBySlug, failedSlugs,
headline) e emptyPrompt com headline.

O residual GOD: o glance ainda é **lista de pastas/repos**, não um **ritmo de 5s**
“onde o trabalho ainda está fora da main em todo o workspace”.

1. **Capsule/headline** existe (`model.headline`, scan clean → “código”) mas a
   hierarquia visual não garante **repos com sem retorno primeiro** sem inventar
   contagens.
2. **Mute/failed slugs** já no pack (`repos_mute`) — a face lista precisa
   **declarar** mute, não zerar como “limpo”.
3. **Pack** lista totais; falta **top attention subjects** (repos que pedem
   julgamento primeiro) sem fabricar ranking Core.
4. **~61 peels Radar** (~1.2k LOC) — W3 funde folder/row/sections micro após DoD
   de glance.

Dual-count fleet-wide com issue lines = §5; casca usa só `issuesBySlug` e
headline **já** no model.

---

## Patamar

| Antes | Depois |
|---|---|
| Radar = fleet locator + pill | Radar = **5s fleet judgment** + pill |
| Mute só no pack | Mute/failed **visível** e honest |
| Order genérica | Severe / with-issues surface first (dados reais) |
| Peel fog rows | Instrumento legível; W3 fuse |

Δ = soberania **multi-repo** (ritual semanal do operador) sem área nova.

---

## Arquitetura

### Princípios

- **Só dados hidratados.** `issuesBySlug`, `failedSlugs`, `headline`, workspace
  folders/recents — zero inventar total reconciliado com Core dual-unit.
- **Silence when clean.** Se scan clean / zero issues → capsule calma (“código”
  ou silence), não “0 problemas!”.
- **Severe first.** Repos com `issuesBySlug[slug]` non-empty sobem; failed/mute
  em seção ou badge “mudo”, não contam como limpos.
- **Pack enriquece, não mente.** Top N slugs com issues + absences; failed list.
- **Pílula inalterada em chrome** (WAVE-005); só pack/emptyPrompt se headline
  fleet melhorar.
- **Casca only.** Sem novo endpoint scan.

### Glance layout (conceitual)

```
[ capsule: headline | silence if clean ]
[ alarm strip if any — existing AlarmCapsule path ]
[ folders ]
[ repos / recents — sorted: with issues → rest; mute marked ]
[ AgenticAskDock — pack top attention ]
```

### Fora de escopo

- Dual-count Core reconcile.
- Agent filter.
- Metal graph.
- Redo graph map WAVE-001.
- WAVE-009 depth sheets (outra onda).

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `AtlasCodeRadarSections*` / capsules | Glance capsule + silence/clean |
| `AtlasCodeRadarRows*` / folder rows | Sort/badge severity; mute honesty |
| `AtlasCodeRadarLoadedContent*` | Order composition |
| `AtlasCodeRadarAskContext.swift` | Top attention subjects in facts |
| `AtlasCodeRadarView+A11y*` | Spoken ≡ visual |
| Failure path | Prefer WAVE-008 shared se landed |

### W3

| Alvo | Estimativa |
|---|---|
| Fuse folder/row/sections micro | **−150…−400** |

`WAVE-011-compress.md`.

---

## DoD (≥5)

1. Capsule headline = fleet sem-retorno **ou** silence/clean — uma voz com
   `model.headline` / scanState (sem inventar).
2. Repos com issues **surface first** (order from real `issuesBySlug`).
3. Failed/mute slugs **declarados** na UI (não zeroed as clean).
4. Pill pack lista top attention subjects + absences; emptyPrompt alinhado.
5. Tap repo → graph sem regressão de honesty de filtro.
6. A11y spoken matches visual hierarchy.
7. Gates; hosts ≤400; W3 fuse peels tocados.

---

## Anti-objetivos

- Inventar total fleet “reconciliado” com Core dual unit.
- Sort cosmético sem dados.
- Collapse Radar host god-file.
- Nova tab Código.

---

## Plano W3

DoD glance → fuse peels rows/sections → delete dead → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — multi-repo judgment |
| DoD≥5 + W3≥150 | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** (61 peels + glance DoD) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Fake totals | critical if | only issuesBySlug |
| Mute as clean | major | explicit badge |
| Sort without data | major | only when scanned>0 |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- explore Code/Grafo: candidate #2 radar-fleet-glance  
