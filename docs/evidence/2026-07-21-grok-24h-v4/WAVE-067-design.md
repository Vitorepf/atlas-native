# WAVE-067 — codigo-radar-screen-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-067-codigo-radar-screen-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A runner-up residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeRadarView` owns contentPhaseID + shell spoken load paths
  **without pure Judgment** for the multi-repo radar screen organ.
- Fleet sort lives in `AtlasCodeRadarJudgment` (024) — **different
  domain** from screen load face (loading/failed/empty/ready).
- Residual after graph screen (061) + ask pill (062): **Radar frota
  shell** still dialect soup on Surface.

## Patamar

| Antes | Depois |
|---|---|
| phase ID strings local | Exclusive radar screen face |
| Spoken shell local | Judgment spoken |
| No pack | Pack face + repo count |

Δ = **soberania da tela Radar** — loading ≠ fail ≠ empty ≠ ready.

---

## Arquitetura

### Princípios

- Casca only; workspace phase + repositoryCount published.
- Honesty: empty workspace ≠ invent repos; fail message published only.
- One domain: radar **screen load** (not fleet issue rank).

### Fluxo

```
phase + repositoryCount + failMessage?
  → AtlasCodeRadarScreenJudgment.face / spoken / pack
  → RadarView peels
```

### Arquivos (≥5)

- `AtlasCodeRadarScreenJudgment.swift` (**new**)
- `AtlasCodeRadarSurface.swift` / View wire
- CODEMAP
- design + compress

### Densidade

Judgment 130–250.

### Fora de escopo

- Fleet sort rewrite  
- Core workspace API  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: loading · failed · empty · ready.
2. Spoken shell from Judgment.
3. contentPhaseID from Judgment.
4. Pack face + repo count.
5. accessibilityValue productWord.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent repos  
- fuse with fleet sort judgment file incorrectly  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire RadarView/Surface  
3. CODEMAP · compress  

Estimativa: **5–6 files · 200–320 LOC**.

## Proof

1. loading → face loading.  
2. empty workspace → empty.  
3. N repos → ready.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Radar screen residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-067 design.*
