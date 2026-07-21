# WAVE-039 — change-review-risk-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-039-change-review-risk-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · 4 idle · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ChangeReviewSections` (~1270 LOC) is a **multi-tipo monólito** with
  findings / patches / governance / controls / tests / a11y — **zero**
  `Judgment` pure module.
- Findings group by axis then `keys.sorted()` **alphabetically** — a
  `critical` finding under "Z" can appear **after** a low "A" axis.
  Within-axis order is wire order, not severity.
- Patches render in wire order — a patch with `riskFlags` can sit under
  a quiet no-flag patch. Operator cannot **judge risk in ≤5s**.
- Sheet chrome has no **face line** summarizing risk (critical/high
  counts + risky patches). Spoken sheet label is generic.
- Severity color/spoken live on `ChangeReviewFindingRow` extensions —
  presentation rule buried in row peel, not reusable grammar.
- After conversation/Autônomos instruments (026–038), residual **change
  review risk organ** is the operator-judgment hole on the existing
  Revisar mudanças surface — not a new area.

## Patamar

| Antes | Depois |
|---|---|
| Achados alpha por eixo | severity-first · axes by worst severity |
| Patches wire order | riskFlags-first · file weight |
| Sem face de risco | Risk face strip exclusive |
| Severity na row | Judgment pure (rank · face · spoken · pack) |
| Sheet a11y genérico | spoken includes risk face |
| Monólito sem grammar | Judgment 200–800 · strip thin |

Δ = **soberania de risco da revisão** — julgar o que dói antes de
aceitar/rejeitar, sem monólito novo nem Core.

---

## Arquitetura

### Princípios

- Casca only; fields already on `AtlasTraceChangeReview` (Finding
  severity/category, Patch riskFlags, Control/Test status).
- Honesty: empty findings/patches → quiet face if surface exists;
  no invent severity.
- Severity grammar: `critical` < `high` < `medium` < `low` < nil/unknown
  (lower rank number = higher attention).
- One domain: **change review risk judgment** — not governance rewrite,
  not Arena, not Autônomos.
- Density: Judgment pure; RiskStrip thin; Sections stays 1 domain
  surface; no `*View` route >600 from this wave.

### Fluxo

```
AtlasTraceChangeReview (published)
  → ChangeReviewJudgment.face / rankFindings / rankPatches
  → ChangeReviewRiskStrip (under run header / top of available)
  → FindingsSection uses rankedAxisGroups
  → Patch cards ForEach ranked patches
  → spoken sheet label + pack facts
```

### Módulos

| Nome | Papel |
|---|---|
| `ChangeReviewJudgment` | severityRank · rank · face · pack · spoken |
| `ChangeReviewRiskStrip` | thin chrome face line |
| Findings / Patch peels | consume Judgment (no local sort) |
| A11yID | `reviewRiskFace` |
| CODEMAP | onde muda risk sort |

### Arquivos (≥5)

- `ChangeReviewJudgment.swift` (**new**)
- `ChangeReviewRiskStrip.swift` (**new**)
- `ChangeReviewSections.swift` — wire rank + severity → Judgment
- `ChangeReviewView.swift` — spoken face if needed
- `A11yID.swift` — risk face id
- `App/Atlas/CODEMAP.md`
- evidence design/compress

### Densidade

| Peça | Alvo |
|---|---|
| Judgment | 200–800 |
| RiskStrip | thin ≤200 |
| Sections | still 1 domínio · no multi-domain fuse |
| Route shells | untouched |

### Fora de escopo

- Core / new DTO / invent severity  
- Governance council rewrite  
- Accept/reject policy change  
- Micro tipografia / opacity ladder  
- Arena / Autônomos / Continuity  
- Split completo do monólito Sections (W3 may MARK only; full peel
  split only if ROI without multi-domain)

### §5

`nenhum` — payload já provider-safe em `AtlasTraceChangeReview`.

---

## DoD (≥5)

1. Findings ranked **severity-first** within axis; axes ordered by
   **worst** severity (not alpha-only).
2. Patches ranked **riskFlags count** (desc) then file footprint.
3. Exclusive **risk face**: empty-surface / quiet / elevated / critical
   with product words + spoken.
4. `ChangeReviewRiskStrip` visible when review has surface; silence
   honest when empty.
5. Severity color + spoken **centralized** in Judgment (rows call it).
6. Sheet / available spoken includes face summary when risk present.
7. Controls/tests with fail/error status elevated above pass (honest
   published status only).
8. Gates: `AtlasCoreChecks` + `make build` + `grok-god-wave-guard` green.
9. CODEMAP line: change-review risk sort → Judgment.

## Anti-objetivos

- invent critical from nil severity  
- alpha sort pretending “judgment”  
- micro-WAVE rename-only  
- Core touch  
- fuse governance + patch + arena  
- dogmatic file-count peel storm  

## Plano W2 / W3 GOD

### W2 implement

1. Write `ChangeReviewJudgment` (rank + face + pack + spoken + severity).
2. Write `ChangeReviewRiskStrip` thin face chrome.
3. Wire `ChangeReviewFindingsSection` → `rankedAxisGroups`.
4. Wire patch `ForEach` → `rankPatches`.
5. Wire controls/tests order if cheap pure ranks.
6. Point FindingRow severity helpers at Judgment.
7. A11yID + sheet spoken.
8. CODEMAP.

### W3 compress

1. Delete duplicate severity spoken/color on row if fully moved.
2. MARK densos if touched.
3. `WAVE-039-compress.md` + DONE + regen + LEDGER.
4. Density guard: Judgment ≤800; no file >2000 from this wave.

Estimativa: **6–9 files · 350–550 LOC** product real (not fuse cosmetics).

## Proof / device

1. Review with mixed severity findings → critical/high first visually.  
2. Patch with riskFlags above quiet patches.  
3. Face strip shows counts; a11y id `review-risk-face`.  
4. Nil/empty findings → quiet face if other surface; no alarm invent.  
5. DEVICE_PENDING (passcode).

## Council

Empty QUEUE after WAVE-038 + idle passes 3–4 (MARK EditorialTurn /
PlanCard). Policy: max 2 idle then self-WAVE only at A bar — this design
passes §WAVE (≥120 lines · ≥5 files · DoD≥5 · casca residual real).

## §WAVE self-check

1. Patamar sim (risk judgment, not typography)  
2. DoD≥5 sim  
3. Casca desbloqueada sim  
4. Design ≥120 sim  
5. Não cabe em &lt;30 min / &lt;5 files sim  
6. Densidade agent-optimal no plano sim  

---

## Notas de implementação

- Severity map case-insensitive; unknown → lowest attention, keep
  wire-stable secondary key (index) for sort stability.
- Axis label still published category; `"GERAIS"` for nil category.
- `hasReviewSurface` stays in sheet — face uses same honesty gate.
- Pack facts usable later by conversation ask; wire if host already
  packs review (optional). Prefer strip + ranks as product core.

## Residual explicit

- Full Sections monólito split → future idle extract only same domain.
- PlanCard step judgment → separate residual, not this wave.
- App Group Continuity BLOCKED.

---

*End WAVE-039 design · implementer self-WAVE · factory continues.*
