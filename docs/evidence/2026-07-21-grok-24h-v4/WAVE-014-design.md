# WAVE-014 — plan-timeline-cockpit-instrument

**Status:** design · proposed  
**Wave:** `WAVE-014-plan-timeline-cockpit-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **high**  
**Rank:** 5  

---

## Problema

Entre o **pulso live** (WAVE-006 strip) e o **julgamento terminal** (WAVE-012
aftermath) falta o instrumento contínuo: **onde estamos no roteiro?**

1. **PlanCard** (~139 peels no ecossistema plan) — steps, revisions, archive —
   “o mapa que o servidor computou”; silence-when-no-plan nem sempre limpo.
2. **LiveTimeline** (shared residual com 012) — narrativa de atividade na
   ribbon; filtros presentation-only; peel fog.

Sem Plan+Timeline como **cockpit de progresso do trabalho**, o strip é um
pulso e o proof um post-mortem — sem “em que passo do plano estamos?”.

WAVE-012 pode fundir Timeline sob judgment grammar; 014 é o **roteiro**
(PlanCard) + regra de coexistência strip=now / plan=roteiro / timeline=narrativa.
Se 012 já estruturou Timeline, 014 foca Plan + glue; se 012 ainda não landed,
014 inclui Timeline residual.

---

## Patamar

| Antes | Depois |
|---|---|
| Plan peel fog; timeline dialect | Cockpit **roteiro + narrativa** |
| Fake progress risk | Steps só de `executionProgress` / checkpoint real |
| Dual “progress” strip vs plan | Strip = now; plan = map; timeline = story |
| Silence broken when no plan | Plan **ausente** quando model nil |

Δ = continuidade operacional durante o run (não só start/stop).

---

## Arquitetura

### Princípios

- **Casca only.** Plan/progress/timeline do model.
- **Silence law:** sem plan publicado → zero PlanCard theater.
- **Steps honest:** never mark done sem progresso real.
- **Revisions** só se model publica archive.
- **Coexist 006:** strip primary now; plan não duplica N/M do strip sem necessidade.
- Hosts ≤400.

### Layout conceitual

```
[ ExecutingStrip — now ]          // 006 owned
[ PlanCard — roteiro if present ] // 014
[ LiveTimeline — story ]          // 012/014 shared residual
[ StateCard / Proof — judgment ]  // 012
```

### Fora de escopo

- Redo 006 strip.
- Full ExecutionProof (012).
- Artifact review (013).
- Arena multi-suite plan Core (`atlas.arena.plan.v1`).
- Nova área.

---

## Arquivos (W2)

| Área | Mudança |
|---|---|
| `PlanCard*` | Instrument; silence if nil; steps honest |
| `LiveTimeline*` (se residual pós-012) | Fuse; filter silence |
| Ribbon mount | Coexistência rules |
| A11y plan/timeline | Estáveis |

### W3

| Alvo | Estimativa |
|---|---|
| Plan + Timeline fuse | **−300…−700** |

`WAVE-014-compress.md`.

---

## DoD (≥5)

1. Plan card **ausente** quando model sem plan (silence law).
2. Steps refletem `executionProgress` / checkpoint real — zero fake done.
3. Revisions archive legível **só** se model publica; sem compare inventado.
4. LiveTimeline: filters presentation-only; empty filter ≠ fail.
5. Spoken grammar: plan progress + timeline row sem dual dialect confuso com strip.
6. Coexiste com ExecutingStrip 006 (strip=now; plan=roteiro).
7. Hosts ≤400; gates verdes.

---

## Anti-objetivos

- Collapse into ConversationView.
- Re-open full Proof (012).
- Micro chip color.
- Invent plan when nil.
- Core plan schema new.

---

## Plano W3

DoD silence+steps → fuse Plan peels → Timeline residual → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — roteiro contínuo |
| DoD≥5 + W3≥300 | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** (100+ peels) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Fake plan steps | critical if | model only |
| Overlap thrash with 012 Timeline | major | coordinate residual; 012 owns judgment timeline first if both open |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- residual #3 plan-timeline  
