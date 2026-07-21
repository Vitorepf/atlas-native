# WAVE-020 — agentic-pack-compiled-grammar

**Status:** design · proposed  
**Wave:** `WAVE-020-agentic-pack-compiled-grammar`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual · W0 council)  
**Δ patamar:** **high**  
**Rank:** 2  

---

## Problema

WAVE-016 fechou o **chrome** da pílula (um dock/face). A lei restante:  
**inteligência = pack compilado**, não segunda UI.

Live: cada `*AskContext` fala um **dialeto** (prosa Home vs key:value Radar vs
Arena tab slice). Absences e **can-do** (só leitura vs CTA run/stop) não
compartilham gramática. Risco de overclaim (“pergunte e o Atlas roda”) quando
`tool_permissions` é read-only.

WAVE-019 fecha o buraco **Grafo** com pack local. Esta onda **unifica a
gramática** em todas as faces ops já vivas — sem fingir Core tipado nem
mandar-fazer.

---

## Patamar

| Antes | Depois |
|---|---|
| Packs por surface, shapes soltos | **Uma** forma: surface · subject · anchors · facts · absences · can_do |
| Do honesty implícita | can_do explícito (read chat vs CTA only) |
| Pill.md matrix stale | Casca alinhada à lei (sem claim Core) |

Δ = órgão de intenção com **mesma inteligência estruturada** em toda ops face.

---

## Arquitetura

### Princípios

- **Casca only.** Shared presentation compiler (enum/helper), hosts donos dos
  dados.
- **Campos canônicos** (mesmo se prosa):
  ```
  surface:
  subject:
  anchors: []
  facts: []
  absences: []
  can_do: read_chat | status_only | cta_only_run_stop | …
  ```
- **WAVE-002 law:** invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts occasion.
- **Não inventar** scores Arena, backlog Autônomos, dual-count grafo.
- **NL não finge write** — can_do declara limite.
- WAVE-019 grafo pack **consome** a mesma forma.
- Hosts ≤400; zero god-file.

### Superfícies (≥6)

Home · Workspace · Code grafo · Radar · Arena (+dest) · Autônomos (+dest).

### Fora de escopo

- Core typed pack schema / Arena pack §5 implement Core.
- tool_permissions write.
- Autônomos POST create.
- Re-chrome docks (016 done).
- App Group Continuity.
- Nova área.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| Shared `AgenticOccasionPack` (or similar) | compiler shape + formatters |
| `HomeAskContext` / `WorkspaceAskContext` | adopt shape |
| `AtlasCodeAskContext` / Radar | adopt (coord 019) |
| `ArenaPremiumAskContext` / `AutonomosAskContext` | adopt + can_do honesty |
| Sheet open sites | turnFacts from compiler |
| pill.md matrix (optional docs) | only if designer path docs — casca honesty |

### W3

| Alvo | Estimativa |
|---|---|
| Fuse/normalize AskContext peels | **−150…−400** |

`WAVE-020-compress.md`.

---

## DoD (≥5)

1. Todas as faces ops emitem pack com eixos **surface · subject · anchors ·
   facts · absences · can_do** (mesmos nomes ou seções equivalentes).
2. invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts **mesma ocasião** por host.
3. Absences explícitas (nunca inventar frota/Arena/create/live engine).
4. **can_do honesty:** chat NL não promete run/stop/pause se só CTA UI faz.
5. Pack **não** vaza na cara da pílula.
6. Grafo/Radar/Arena/Autônomos/Home/Workspace: zero regressão de chrome 016.
7. Gates; hosts ≤400; zero claim de Core pack tipado “done”.

---

## Anti-objetivos

- Reabrir WAVE-016 chrome.
- Dump model JSON.
- Inventar scores / awaiting counts.
- Fingir mandar-fazer.
- Opacity ladder.

---

## Plano W3

Shared compiler → migrate hosts → delete dialect helpers mortos → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — pack grammar organ |
| DoD≥5 + ≥3 surfaces | **SIM** (≥6) |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Overclaim do | critical if | can_do required |
| Fight WAVE-019 shape | major | same compiler |
| World mix | major | surface pure |

**Critical open:** 0.

---

## §5

- Arena Core pack tipado.
- tool_permissions write.
- Autônomos create POST.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- pill residual #2 agentic-pack-compiled-grammar  
- Code residual grafo pack = WAVE-019 sibling  
