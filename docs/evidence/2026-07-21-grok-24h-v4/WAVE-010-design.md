# WAVE-010 — arena-suitesheet-instrument

**Status:** design · proposed  
**Wave:** `WAVE-010-arena-suitesheet-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **med+** (high no residual Arena)  
**Rank:** 5  

---

## Problema

WAVE-004 transformou **ArenaRunSheet** em instrumento (~48→5 peels + worker
honesty). O residual Arena da mesma classe é **`ArenaSuiteSheet`**: ~18–20 peels
(Body/Title, EngineCard/Header/Score, EngineCaptions×3, A11y×5, Presentation,
Toolbar, sparkline) — o operador julga uma suíte medida sob névoa de arquivos.

Agora/Execução/RunSheet **não** redesenhar (já A−). Esta onda = **SuiteSheet
como instrumento de julgamento de suíte** (engines, cases, duration, sparkline
honestos) + compress estrutural.

Pack Core tipado + NL run/stop = §5 — casca não finge do; presentation pack
já destination-true (WAVE-002).

---

## Patamar

| Antes | Depois |
|---|---|
| SuiteSheet peel tower | Instrumento ~5–7 arquivos |
| Capções cases/duration/sparkline espalhadas | Uma árvore; **nunca fabricar 0** |
| A11y fragmentada | Spoken unificado + IDs estáveis |
| RunSheet GOD | SuiteSheet no mesmo padrão de craft |

Δ = profundidade operacional Arena no **último** sheet de julgamento residual.

---

## Arquitetura

### Alvo estrutural (espelho WAVE-004)

```
ArenaSuiteSheet.swift              — host + presentation bind
+Body                              — title header + content
+Engines                           — engine cards (score/header fused)
+Captions                          — cases · duration · sparkline honesty
+A11y                              — captions + close + sheet body spoken
+Toolbar / Presentation            — se não couber no host
ArenaSuiteSparkline*               — keep thin or fuse into Captions
```

### Regras de honesty

1. Cases/duration/sparkline: **nunca** mostrar 0 fabricado quando o model diz
   absent/unknown — silence ou “—”.
2. Score só se o model publica; sem inventar índice.
3. Open path Motor/Results → suite **inalterado** (sem nova rota).
4. Suite-scoped pill pack: **opcional** se sheet open puder alimentar
   presentation facts sem Core; se frágil, documentar e pular (anti-teatro).
5. Hosts ≤400; zero collapse de `ArenaPremiumShell`.

### Fora de escopo

- Redesign Agora state machine / Running / Idle glyphs.
- RunSheet re-peel.
- Plano multi-suíte Core (`atlas.arena.plan.v1`).
- NL mandar rodar suíte via pílula.
- Failure empty canon (WAVE-008) — consumir se já landed.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `ArenaSuiteSheet*.swift` (~18) | Fuse → 5–7 |
| `ArenaSuiteSparkline*.swift` | Thin / fuse captions |
| Call sites Results/Motor | IDs estáveis |
| A11yID Arena suite | Preservar |

### W3

| Alvo | Estimativa |
|---|---|
| Peel fuse | **−250…−500** (classe RunSheet) |

`WAVE-010-compress.md`.

---

## DoD (≥5)

1. SuiteSheet **≤7 arquivos** estruturais (de ~18+).
2. Cases/duration/sparkline: **zero 0 fabricado**; spoken unificado.
3. Path open de Motor/Results inalterado funcionalmente.
4. A11yIDs estáveis (close, engine cards, sheet body).
5. Nenhum host Arena Premium >400 por causa desta onda.
6. Gates guard + checks + build.
7. Honesty: scores só com dado real.

---

## Anti-objetivos

- Restyle Agora/Execução.
- Micro copy de kicker sem fuse.
- Fabricar sparkline “bonita” sem série.
- God-file suite 400+.
- Core plan/batch.

---

## Plano W3

DoD instrument → fuse captions/a11y/engine → delete dead → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — instrument suite |
| DoD≥5 + W3≥250 | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** (18+ peels) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Fabricate zeros | critical if | explicit DoD2 |
| Break open path | major | no route change |
| Pack suite overclaim | minor | optional / skip |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- explore pill/chat/Arena: top #2 SuiteSheet  
- WAVE-004 residual compress note  
