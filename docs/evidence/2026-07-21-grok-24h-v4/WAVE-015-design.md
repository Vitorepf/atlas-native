# WAVE-015 — home-intention-port

**Status:** design · proposed  
**Wave:** `WAVE-015-home-intention-port`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **med+**  
**Rank:** 8  

---

## Problema

A pílula da Home é a **porta diária de intenção**, mas o tap abre o **picker de
workspace** (router Cursor-like), não uma conversa free com `HomeAskContext`
direto. Outras faces ops (Arena, Code, Autônomos) abrem conversa+pack na hora.

1. **Intention fork:** invite = “Escreva ao Atlas” (agêntico); action = escolher
   repo primeiro. Free path só após “Sem repositório”.
2. **Pack thin (legal):** threads, live hub ≤5, workspaces, absences — ok como
   partida, mas pode aprofundar **só Home-local** (free vs workspace counts,
   recent free titles, remote vs local live) sem misturar Arena/Autônomos
   (pack crime).
3. **OPERAÇÃO / LiveNow** — já settled (home-limpa; Session Hub). Não redesenhar
   glance com regression theater (veto operador 2026-07-18).

Isto **não** é micro de spacing. É o **órgão de partida** alinhado à lei da
pílula: intenção em linguagem natural com pack da ocasião.

---

## Patamar

| Antes | Depois |
|---|---|
| Pill → picker obrigatório | **Primary free** + workspace secondary |
| Pack partida mínimo | Pack Home-local rico + absences |
| Intention vs router tension | Uma porta; repo é opção |

Δ = fricção zero para começar a falar com o Atlas (ainda com workspace
alcançável).

---

## Arquitetura

### Princípios

- **Casca only.** Routing `Route.new` já existe; free = `workspaceKey: nil`.
- **Primary free path:** tap pill → new conversation free com pack Home.
- **Workspace secondary:** long-press, trailing control, ou sheet option —
  picker **permanece** acessível; não some.
- **Pack Home-local only:** nunca dump Arena scores / Autônomos backlog.
- **Invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts** (WAVE-002 law).
- **OPERAÇÃO clean:** no regression badge; domain-unavailable only if true.
- A11y `home-input-pill` estável.

### Fluxo

```
tap AgenticPill (home)
  → Route.new(workspaceKey: nil)  // free primary
  → ConversationView emptyPrompt/suggestions/facts = HomeAskContext

secondary:
  long-press OR trailing workspace glyph OR “escolher repo”
  → existing picker sheet
```

### Fora de escopo

- OPERAÇÃO multi-metric dashboard.
- LiveNow Route / peel craft.
- Arena regression on home.
- Core typed Home pack.
- Continuity / widgets.
- Nova tab.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `RootView+InputBar.swift` (+ related) | Primary free; secondary picker |
| `HomeAskContext.swift` | Deepen local facts |
| New conversation seed path | Ensure pack travels (WAVE-002 parity) |
| Picker sheet | Still reachable; a11y |
| XCUITest / design-tour if picker-first | Update expectations |

### W3

| Alvo | Estimativa |
|---|---|
| Routing + pack + picker chrome | **−80…−250** (Δ product > compress) |

`WAVE-015-compress.md`.

---

## DoD (≥5)

1. **Primary free:** tap pill → free conversation + `HomeAskContext` sem picker
   obrigatório.
2. **Pack deepen (Home-local):** free vs workspace thread counts; até N títulos
   free recentes; live hub local/remote; absences explícitas; **zero** dump
   Arena/Autônomos.
3. **Invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts** mesma ocasião.
4. **OPERAÇÃO stays clean** — no regression theater.
5. **Workspace still reachable** (secondary path); a11y picker when shown.
6. `home-input-pill` ID estável; path testável.
7. Gates verdes; zero Core.

---

## Anti-objetivos

- Reintroduzir chips/filters home-limpa.
- OPERAÇÃO glance fake badges.
- LiveNow peel-only wave.
- Pack world-mix.
- Opacity tokens.

---

## Plano W3

DoD free-first → pack deepen → fuse picker residual → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — intention port |
| DoD≥5 + multi-touch Home surfaces | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** (routing product, not copy) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Lose workspace path | critical if | secondary mandatory DoD5 |
| Pack mixes worlds | critical if | Home-local only |
| Break XCUITest picker-first | major | update tests |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- Home+proof residual #2 home-intention-port  
