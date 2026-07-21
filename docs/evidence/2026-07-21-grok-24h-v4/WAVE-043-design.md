# WAVE-043 — atlas-code-repo-health-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-043-atlas-code-repo-health-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A-bar self-WAVE)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Código surface publishes **violations + heal + week + mirror** but the
  operator still judges health by **four dialects**: `statusHeadline`
  (model), mirror card copy, week metrics, heal CTA — no pure exclusive
  **repo health face**.
- Pack (`AtlasCodeAskContext`) packs graph slice + heal canDo, but does
  **not** surface a single `repo_health_face` for week/mirror pressure.
- Mirror blocked (secret) can sit **below** the fold while graph looks
  "clean" on trunk — operator may miss the Mac leave-block.
- Week quiet vs active and heal receipt are honest peels (WAVE-009) but
  lack shared product grammar with scan state.
- Residual after graph commit-map judgment (028) and radar: **repo health
  organ** still View-scattered.

## Patamar

| Antes | Depois |
|---|---|
| 4 dialects (status/mirror/week/heal) | One exclusive health face |
| Mirror block easy to miss | Face elevates blocked |
| Pack without health face | `repo_health_face` + summary |
| Week/heal separate spoken | Judgment summary compound |
| No strip | Thin health strip above list tail |

Δ = **soberania de saúde do repo** — julgar quiet / fora / espelho /
curado em ≤5s.

---

## Arquitetura

### Princípios

- Casca only; fields already on `AtlasCodeModel` + `AtlasCodeMirrorResponse`.
- Honesty: nil violations → unknown scan; nil week → absence; never invent
  heals/commits.
- Attention priority (exclusive face lead):
  1. mirror **blocked** (secret)
  2. scan **violating**
  3. heal receipt present on clean scan
  4. week **active** (commits/heals/prevented)
  5. clean quiet
  6. unbound / loading
- One domain: código repo health — not Arena, not Autônomos.
- Density: Judgment pure; strip thin; no multi-domain fuse of Surface.

### Fluxo

```
model (violations, heal, week) + mirrorModel.response
  → AtlasCodeRepoHealthJudgment.face / summary / pack
  → AtlasCodeRepoHealthStrip (list head or before tail)
  → AskContext facts include health face
  → Mirror spoken can align productWord (optional thin)
```

### Módulos

| Nome | Papel |
|---|---|
| `AtlasCodeRepoHealthJudgment` | face · summary · pack · spoken |
| `AtlasCodeRepoHealthStrip` | thin exclusive chrome |
| AtlasCodeSurface / list | embed strip |
| AtlasCodeAskContext | pack health |
| CODEMAP | onde muda repo health |

### Arquivos (≥5)

- `AtlasCodeRepoHealthJudgment.swift` (**new**)
- `AtlasCodeRepoHealthStrip.swift` (**new**)
- `AtlasCodeSurface.swift` — embed strip
- `AtlasCodeAskContext.swift` — pack
- `A11yID.swift` — codeRepoHealth
- `CODEMAP.md`
- evidence design/compress

### Densidade

Judgment 200–800 · Strip thin · Surface still 1 domain · no Shell >600.

### Fora de escopo

- Core statusHeadline rewrite (Codex model seam if needed)  
- Dual-count obra/branch §5  
- Agent filter DTO  
- Micro tipografia  
- Radar multi-repo rewrite  

### §5

Optional note: dual-count still Core. This wave does not invent counts.

---

## DoD (≥5)

1. Exclusive face: unbound · unknown · clean · healed · weekActive ·
   violating · mirrorBlocked (product words + spoken).
2. Priority: blocked > violating > healed > week > clean.
3. `AtlasCodeRepoHealthStrip` on graph list when loaded (silence unbound).
4. Ask pack includes `repo_health_face` + summary facts/absences.
5. Summary line compounds scan + week + heal honesty without invent.
6. A11y id `code-repo-health`.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent violations  
- fuse mirror into monólito Surface  
- Core  
- micro-WAVE rename-only  
- change graph node rank (already GraphJudgment)  

## Plano W2 / W3

1. Judgment  
2. Strip  
3. Embed in list  
4. AskContext pack  
5. CODEMAP · compress · DONE · regen · LEDGER  

Estimativa: **6–8 files · 300–450 LOC**.

## Proof

1. Violating repo → face violating + count.  
2. Clean + heal → face healed.  
3. Mirror blocked → face blocked even if scan clean.  
4. Week active metrics in summary.  
5. Nil week → absence honesty.  
6. DEVICE_PENDING.

## Council

Empty QUEUE after 039–042 + idle peel. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-043 design.*
