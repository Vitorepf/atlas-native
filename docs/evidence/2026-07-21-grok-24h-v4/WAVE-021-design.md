# WAVE-021 — arena-premium-score-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-021-arena-premium-score-judgment-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual · W0 council)  
**Δ patamar:** **high**  
**Rank:** 3  

---

## Problema

WAVE-004 (RunSheet) e WAVE-010 (SuiteSheet) instrumentaram **disparo e suíte**.
O residual Arena Premium é o **julgamento de scoreboard** — faces que contam
0–10 / com vs sem Atlas / regressão em **dialetos paralelos**:

1. **Results/Motor** — índice hero, delta, chart, lista de suítes.
2. **Frota** — ranking de motores por multiplier.
3. **Capacidades** — coverage counts + legend tracks.
4. **Alertas** — regressões + attention.
5. **Comparison** — silence-when-no-pair (lei boa, isolada).

O operador reaprende “o que é 0–10” em cada aba. Não é nova área — é **uma
gramática de julgamento** nas faces já vivas.

---

## Patamar

| Antes | Depois |
|---|---|
| Cinco dialetos de score | **Um** score judgment instrument |
| 0 fabricado / kicker órfão | Silence rules compartilhadas (lei Comparison) |
| Alertas ≠ Results voice | Mesma voz + open SuiteSheet |

Δ = profundidade operacional Arena no eixo **julgar medição**, não só rodar.

---

## Arquitetura

### Princípios

- **Casca only.** Scores só se model publica; never fabricate 0.
- **Estados exclusivos:** `unmeasured | partial | published | regressed | quiet-healthy`.
- **Comparison silence law** = lei global de provisional/final kickers.
- **Alertas ≡ Results regressions** mesma voz; open SuiteSheet inalterado.
- Não redesenhar Agora state machine (já forte).
- Hosts ≤400; zero collapse shell.

### Fora de escopo

- Multi-suíte plan Core (`atlas.arena.plan.v1`).
- NL run/stop theater.
- Re-peel RunSheet/SuiteSheet.
- App Group.
- Nova tab Arena.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `ArenaPremiumResultsView*` | consume shared score grammar |
| `ArenaPremiumFleetView*` | same |
| `ArenaPremiumCapabilitiesView*` | same |
| `ArenaPremiumAlertsView*` | same |
| `ArenaPremiumComparison*` | export silence law as shared |
| Shared score helpers (new presentation) | index/Δ/absence formatters |
| A11yID arena premium | stable |

### W3

| Alvo | Estimativa |
|---|---|
| Fuse score helpers + tab residual | **−200…−500** |

`WAVE-021-compress.md`.

---

## DoD (≥5)

1. **Uma score grammar** em Results · Fleet · Capabilities · Alerts · Comparison
   (0–10, com/sem Atlas, Δ só se ambos publicados; never fabricate 0).
2. **Estados exclusivos** unmeasured | partial | published | regressed | quiet-healthy.
3. **Alerts ≡ Results** mesma voz; open SuiteSheet path estável.
4. **Capabilities** counts da mesma grammar (sem “tracks” que briguem com Motor).
5. **Comparison silence** é lei de todos kickers provisional/final.
6. A11y spoken ≡ visual; IDs estáveis.
7. Hosts ≤400; gates; zero invent plan multi-suíte.

---

## Anti-objetivos

- Redesign Agora idle/running.
- Re-fuse RunSheet.
- Invent scores.
- Opacity ladder.
- Nova área.

---

## Plano W3

Shared grammar → migrate 5 faces → delete dialect helpers → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — scoreboard judgment |
| DoD≥5 + multi surface | **SIM** (5 faces) |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Fabricate 0 | critical if | DoD1 |
| Break SuiteSheet open | major | no route change |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- Continuity/Arena residual #2 arena-premium-score-judgment  
