# WAVE-019 — codigo-grafo-occasion-pack

**Status:** design · proposed  
**Wave:** `WAVE-019-codigo-grafo-occasion-pack`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual · W0 council)  
**Δ patamar:** **max**  
**Rank:** 1  

---

## Problema

A lei da pílula: **inteligência = pack compilado da ocasião**. Live 2026-07-21:

| Superfície | Pack local |
|---|---|
| Home / Workspace / Arena / Autônomos / **Radar** | `*AskContext.facts(...)` → turnFacts |
| **Grafo** | `AtlasCodeAskContext` = **só** invite + emptyPrompt |

O grafo já tem **âncora soberana** (WAVE-001: swipe → legend → emptyPrompt) e
**askCode** facts pós-servidor (`askModel.facts`), mas **não** compila o pack
base da tela (repo · trunk/HEAD · sem retorno · filtro · focus · absences)
antes do primeiro token — ao contrário do Radar (`AtlasCodeRadarAskContext`).

Canon `atlas-native-agentic-pill.md`: pack grafo = repo + trunk + sem retorno +
nó de foco; swipe **enriquece**; pack **nunca** na cara da pílula. Live falha
no “compila a ocasião”.

Isto **não** é copy. É o instrumento de julgamento soberano sem inteligência
anexada — dashboard de commits com chat grudado.

---

## Patamar

| Antes | Depois |
|---|---|
| Grafo ask = invite + emptyPrompt + facts só do server ask | Pack **ocasião** + opcional ask server |
| Radar tem pack; grafo não | Mesma gramática de inteligência |
| Absences implícitas | Absences explícitas (dual-count, agent filter, etc.) |

Δ = grafo entra na era agêntica de verdade (pack da tela + intenção livre).

---

## Arquitetura

### Princípios

- **Casca only.** Presentation pack; zero Sources / model logic.
- **Uma gramática de campos** (prosa ou key:value, **mesmos eixos**):
  `surface · subject · anchors · facts · absences`.
- **turnFacts** = occasion pack **primeiro**; se houver `askModel.facts` do
  server, **anexa** com label claro — nunca inventar commits.
- **Focus enriquece:** `askFocusNode` / legend / state / rule se existirem.
- **Clear remove** bloco de focus do pack; resto da ocasião permanece.
- **Pack nunca na cara** da pílula (só invite/legend).
- Dual-count banner vs issues: **declarar** uncertainty em absences — **não**
  reconciliar inventando totais (§5 Core).
- Hosts ≤400.

### Fluxo

```
open ask sheet / send first turn
  → turnFacts = AtlasCodeAskContext.facts(
        model: graph model state,
        focus: askFocusNode / sheetFocusLegend,
        filter: graph filter,
        …
     )
  → optional + askModel.serverFacts if present
  → emptyPrompt(focusLegend:) unchanged (WAVE-001)
```

### Fora de escopo

- Dual-count unit Core reconcile.
- Agent filter DTO (M105).
- tool_permissions write / mandar-curar.
- Radar pack rewrite.
- Metal graph.
- Nova área.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `AtlasCodeAskContext.swift` | `facts(...)` occasion compiler |
| `AtlasCodeView+Sheets+AskConversation.swift` | wire turnFacts = occasion (+ server) |
| `AtlasCodeAskModel` consumers (presentation only) | merge labels if needed |
| A11y / empty prompt | no regress WAVE-001 |
| Optional shared helper if 2nd consumer | only if Arena/Home reuse same shape |

### W3

| Alvo | Estimativa |
|---|---|
| Fuse AskContext/sheet micro if any | **−80…−250** (Δ product first) |

`WAVE-019-compress.md`.

---

## DoD (≥5 — observável)

1. `AtlasCodeAskContext.facts(...)` publica `surface: code.graph` (ou equivalente
   honesto), repo, trunk/HEAD se conhecido, statusHeadline/scanState, filter,
   worktree count se real, focus (hash·subject·state) se âncora, **absences**.
2. `turnFacts` da conversa ask do grafo **inclui** occasion pack (não só server
   ask facts).
3. Swipe/provenance focus **enriquece** pack; clear remove focus block.
4. Pack **não** aparece na cara da pílula (só invite/legend).
5. emptyPrompt/invite/suggestions = mesma ocasião (WAVE-001/002 law).
6. Dual-count / agent filter: absence explícita, zero fake reconcile.
7. Gates; hosts ≤400; Radar pack **não** regride.

---

## Anti-objetivos

- Inventar commits ou scores.
- Dump JSON do model inteiro.
- “Só emptyPrompt copy”.
- Core dual-count claim.
- Collapse AtlasCodeView god-file.
- Nova tab Código.

---

## Plano W3

DoD pack wire → fuse peels Ask se nascerem → numstat honesto.

---

## Critérios §B

| Critério | Pass? |
|---|---|
| Muda patamar | **SIM** — pack é metade do órgão agêntico |
| DoD ≥5 | **SIM** (7) |
| Casca-desbloqueada | **SIM** |
| Design ≥80 + arch + anti + W3 | **SIM** |
| Anti-micro | **SIM** — gap transversal vs Radar/Arena |

---

## Reviewer (self · 0 critical)

| Issue | Sev | Resolution |
|---|---|---|
| Invent dual-count total | critical if | absences only |
| Server facts overwrite occasion | major | occasion first, label merge |
| Pack on pill face | major | never |
| World mix Arena | major | surface code.graph only |

**Critical open:** 0.

---

## §5 (não bloquear casca)

- Dual unit banner vs issue lines (Codex).
- Agent field graph node (M105).
- Typed Core pack schema (future).

---

## Approval

- [x] §B pass  
- [x] Sections complete  
- [ ] approved  

## Explores (W0 · 2026-07-21)

- Code residual: #1 grafo occasion pack  
- Pill residual: pack grammar after chrome 016  
- Continuity/Arena: 018 / scoreboard separate  
