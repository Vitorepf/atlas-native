# WAVE-024 — radar-fleet-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-024-radar-fleet-judgment-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual · W0 council ≥3 explore)  
**Δ patamar:** **high**  
**Rank:** 2 (regen mechanical)

---

## Problema

O Radar é a **porta multi-repo** do Atlas Código — aberta **antes** de qualquer
grafo. WAVE-011 marcou compress (View + Surface + Rows) mas o **DoD de
julgamento de frota em 5s** **não está live**:

1. **Order wire-default** — `ForEach(workspace.recents|folders|loose)` sem
   **severe-first** (`issuesBySlug[slug]` non-empty sobe) quando scan existe.
2. **Mute/failed** — `failedSlugs` só no pack como `repos_mute`; **sem badge
   “mudo / não respondeu”** na row → repo mudo lê como limpo.
3. **Pack incompleto** — totais + headline; falta **top attention subjects**
   (slug + severidade/count real) para a pílula (WAVE-020 grammar already
   hosts facts/absences/can_do).
4. **~61 peel markers** ainda em RadarView (~325) + Surface (~325) + Rows
   (~425) — instrument legível + W3 fuse.

Isto **não** é dual-count Core (§5). Casca usa só `issuesBySlug`,
`failedSlugs`, `headline`, folders/recents **já hidratados**.

WAVE-019/020 fecharam pack do **grafo** e a gramática compartilhada. O buraco
restante no eixo Código multi-repo é o **ritmo de julgamento da frota**.

Council Code explore 2026-07-21: residual #1 Código = este (high).

---

## Patamar

| Antes | Depois |
|---|---|
| Radar = locator + pill | Radar = **5s fleet judgment** + pill |
| Mute só no pack | Mute/failed **visível** (badge/line) |
| Order genérica | With-issues first (dados reais); else wire order |
| Pack totals only | Top attention subjects + absences |
| Peel forest rows | Instrument legível; W3 fuse |

Δ = soberania **multi-repo** (ritual semanal) — eixo Código / grafo portal.

---

## Arquitetura

### Princípios

- **Casca only.** Zero novo endpoint scan; zero inventar merge/cure counts.
- **Só dados hidratados.** Sort/badge only when `issuesBySlug` / `failedSlugs`
  known; unscanned keep wire order (honesty).
- **Silence when clean.** Capsule calma (“código” / silence) se zero issues e
  scan clean — never “0 problemas!”.
- **Severe first.** Repos com issues non-empty sobem dentro da secção; mute
  marcado, **nunca** conta como limpo.
- **Pack:** top N attention (slug + signal count from real arrays) +
  `repos_mute` + absences; `can_do: .readChat` (020).
- **Chrome pílula** inalterado (016 dock); só pack/emptyPrompt se headline
  fleet melhorar.
- Hosts ≤400.

### Glance layout alvo

```
[ capsule: headline | silence if clean ]
[ alarm strip if any — existing path ]
[ folders — optional issues-first children ]
[ repos/recents — sorted: with issues → rest; mute badge ]
[ AgenticAskDock — pack top attention ]
```

### Fora de escopo

- Dual-count Core reconcile / agent filter DTO.
- Metal graph / TreeSitter.
- Grafo commit-map instrument (runner-up residual — separate wave if needed).
- Provenance/Why depth (009 residual craft).
- App Group widgets.
- WAVE-023 presence (other axis).
- Nova área.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `AtlasCodeRadarView.swift` | Section composition + sort hooks |
| `AtlasCodeRadarSurface.swift` | Capsule/silence + loaded order |
| `AtlasCodeRadarRows.swift` | Row mute badge; severity chrome; pack top attention |
| `AtlasCodeWorkspaceModel(+Scan).swift` | **Read only** for sort keys — presentation helpers may live in Radar* if pure UI |
| A11y Radar | Spoken ≡ issues / mute / order |

### W3

| Alvo | Estimativa |
|---|---|
| Radar peel collapse (a11y micro / section peels) | **−200…−450** |

`WAVE-024-compress.md`.

---

## DoD (≥5)

1. Recents (and loose if applicable) sorted **issues-first** from real
   `issuesBySlug` when scanned; wire order when no scan data.
2. Failed/mute slugs show explicit **mudo / não respondeu** UI — never read as
   limpo.
3. `AtlasCodeRadarAskContext.facts` emits **top attention subjects** (slug +
   issue signal from data) + existing absences; invite silence-when-clean law.
4. Capsule one voice: clean → quiet; violating → headline; mute → honest
   unknown (existing scanState law).
5. Spoken a11y hierarchy matches visual (issues / mute / order).
6. Tap repo → grafo unchanged; dock/pack 016/020 no regression.
7. Peel markers collapse to readable instruments; hosts ≤400; gates green.

---

## Anti-objetivos

- Inventar fleet totals / dual-count.
- Fake ranking without issuesBySlug.
- God-file Radar host.
- Opacity ladder as “judgment”.
- Reabrir grafo map / 009 depth as this wave.
- Claim scan Core “fixed”.

---

## Plano W3 (Implementer)

1. Pure sort helpers: `sortedForJudgment(repos:issuesBySlug:failed:)` —
   presentation-only.
2. Row badge mute from `failedSlugs.contains`.
3. Pack: top N by issue count (stable tie-break slug).
4. Fuse a11y micro-peels in Rows/Surface.
5. Compress + DONE 024 + regen.

---

## Council notes

- Live pack: totals + mute list, **no top attention list**
  (`AtlasCodeRadarRows.swift` AskContext)
- ForEach wire order: `AtlasCodeRadarView.swift` folders/loose/recents
- Peel ~61 across 3 hosts (~1.1k LOC)
- 011 compress thin; product DoD incomplete

## Runner-up (not this wave)

- `codigo-commit-map-instrument` — `AtlasCodeSurface` ~974 + CommitRowBody ~613
  + pack filter/worktrees residual 019 — next Código if 024 lands and queue
  needs refill.
- `change-review-signature` — `ChangeReviewSections` ~1352 god-concat 013 —
  Assinatura craft; consider if operator veto fog > fleet door.

---

## Rank rationale

Δ **high** (not max): completes incomplete 011 product on Código multi-repo
door; max reserved for WAVE-023 presence organ that spans Continuity+Conversa.
