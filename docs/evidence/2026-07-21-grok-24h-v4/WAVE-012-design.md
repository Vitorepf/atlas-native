# WAVE-012 — conversation-run-aftermath-instrument

**Status:** design · proposed  
**Wave:** `WAVE-012-conversation-run-aftermath-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **max** (eixo conversa pós-WAVE-006)  
**Rank:** 1 (entre proposed abertos após 006/007 land)  

---

## Problema

WAVE-006 entregou o instrumento de **voo** (ExecutingStrip unificado + composer
estrutural). O residual explícito do compress report e do design 006:

> ExecutionProof / ExecutionStateCard **intentionally out of this wave**  
> Dual surface: ReconnectBanner still mounts in ExecutionRibbon while strip is primary

O operador já **pilota** o run. Ainda **não julga o corpse e a interrupção** sob
uma gramática:

1. **ExecutionProof** (~41 peels) — collapse/expand, activities, decide, quality,
   artifacts CTA, scrubber — floresta pós-turno.
2. **ExecutionStateCard** (~60 peels) — attention / awaiting / failed / recovering /
   choices (C14) — segunda árvore de “o que fazer agora”.
3. **LiveTimeline** (~99 peels no ecossistema) — narrativa na ribbon, filtros,
   rows — terceira voz de progresso.

Três dialetos de julgamento competem com o strip limpo. Patamar GOD do chat de
**programação com agentes** exige: **operar (006) + julgar (012)** no mesmo órgão.

---

## Patamar

| Antes | Depois |
|---|---|
| Live strip GOD; proof/state/timeline fog | **Um** grammar de julgamento do run |
| Attention/fail parece “outro produto” | Badge·tint·spoken alinhados ao phase language 006 |
| Dual reconnect strip + ribbon banner | Regra de exclusão mútua (strip primary) |
| ~200 peels judgment families | Torres estruturais (~8–15 arquivos reais) |

Δ = fechar o ciclo diário do agente: **voar → interromper → decidir → fechar**.

---

## Arquitetura

### Princípios

- **Casca only.** Zero Sources / ConversationModel logic / Makefile.
- **Fases só publicadas.** Mapear `AtlasExecutionPresentationState` e flags do
  model; nunca inventar botão/risco/score.
- **Strip = now; aftermath = judgment.** 006 não reabre; 012 não re-peel strip.
- **Fail ≠ empty** (WAVE-003) + load fail canon (008 se landed) preservados.
- **Hosts ≤400.** Proibido collapse `ConversationView` god-file.
- **Peels = W3**, não identidade.

### Composição alvo

```
ConversationRunCockpit (conceitual)
├── live-secondary   — ribbon reconnect/silence só se strip NÃO é primary face
├── attention        — StateCard phases (choose/retry/steer/timer)
├── narrative        — LiveTimeline (filter honest; empty = absence)
└── terminal         — ExecutionProof (header 3s + expand tree)
```

### Expand Proof (uma árvore)

```
header (collapsed, 3s legível)
expand:
  activities · decide · quality · artifacts CTA · scrubber
spoken compound por phaseID
```

### Dual-surface rule (DoD)

```
if ExecutingStrip shows reconnect for liveBubble B:
  ExecutionRibbon MUST NOT primary-copy the same reconnect (secondary silence OK)
```

### Fora de escopo

- Redo WAVE-006 strip/composer.
- Artifact gallery full + ChangeReview accept (WAVE-013).
- PlanCard primary (WAVE-014).
- Island / App Group.
- Core approval plumbing global “Aprovar”.
- Nova área.

---

## Arquivos (W2)

| Área | Mudança |
|---|---|
| `ExecutionProof*` (~41) | Instrumento estrutural collapse/expand |
| `ExecutionStateCard*` (~60) | Phases C14 1:1; actions model-only |
| `LiveTimeline*` / ribbon activities | Narrative sob mesma gramática |
| `ExecutionRibbon*` dual reconnect | Exclusão mútua com strip |
| `EditorialTurn+*` mount points | Wiring sem god-file |
| A11yID proof/state/timeline | Estáveis; XCUITest |

### W3

| Alvo | Estimativa |
|---|---|
| Fuse Proof peels | −150…−350 |
| Fuse StateCard peels | −150…−350 |
| Fuse Timeline micro | −100…−250 |
| **Meta** | **−400…−900** honest |

`WAVE-012-compress.md` com numstat.

---

## DoD (≥5 — observável)

1. **Um judgment grammar:** attention / await / fail / recover / terminal
   compartilham badge·tint·spoken com language do strip 006 (sem inventar fase).
2. **ExecutionProof estrutural:** expand = activities · decide · quality ·
   artifacts · scrubber numa árvore; header colapsado legível em ~3s.
3. **ExecutionStateCard estrutural:** actions choose/retry/steer só se model
   publica; timer honesty; compound spoken one path.
4. **LiveTimeline:** narrative sob o órgão; empty filter ≠ fail; zero fake steps.
5. **Dual-surface:** strip reconnect primary ⇒ ribbon não double-speaks.
6. **Sem regressão** 006 instrument + fail≠empty; A11y IDs estáveis.
7. Hosts ≤400; gates guard + AtlasCoreChecks + `make build`.

---

## Anti-objetivos

- Re-fuse strip/composer (006 done).
- Opacity ladder / chase file-count.
- Inventar council/diff no proof (013).
- God-file ConversationView.
- Home / Arena / Code scope creep.
- Core edits.

---

## Plano W3

1. DoD grammar + dual-surface first.  
2. Fuse Proof → StateCard → Timeline adjacents.  
3. Delete dead (`rg` 0).  
4. Numstat honesto; residual → 013 se artifacts CTA ainda dialect.

---

## Critérios §B

| Critério | Pass? |
|---|---|
| Muda patamar | **SIM** — julgar o run |
| DoD ≥5 + W3≥400 | **SIM** |
| Casca-desbloqueada | **SIM** (C14 já público) |
| Design completo | **SIM** |
| Anti-micro | **SIM** (~200 peels) |

---

## Reviewer (self · 0 critical)

| Issue | Sev | Resolution |
|---|---|---|
| Invent phase not in model | critical if | map only published |
| Break 006 strip | major | out of scope strip |
| Scope steal 013 artifacts full | major | CTA only; gallery 013 |
| Dual reconnect ambiguous | major | DoD5 explicit |

**Critical open:** 0.

---

## §5

Nenhum para presentation. Se phase flag ausente, absence honesta — não §5 inventado.

---

## Approval

- [x] §B pass  
- [x] complete  
- [ ] approved  

## Explores

- residual high-Δ #1 aftermath  
- Home+proof: proof-cockpit separate from 006  
- WAVE-006-compress residual  
