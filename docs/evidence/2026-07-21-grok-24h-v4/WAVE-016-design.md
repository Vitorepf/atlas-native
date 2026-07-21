# WAVE-016 — pill-chrome-one-machine

**Status:** design · proposed  
**Wave:** `WAVE-016-pill-chrome-one-machine`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **max**  
**Rank:** 1  

---

## Problema

A lei da pílula é **um chrome / um órgão** de intenção. `AgenticPill` e
`AgenticAskDock` (+ `.agenticAskSheetPresentation()`) existem, mas o tree
mostra **primitivos sem máquina unificada nos hosts**:

1. **`AgenticAskDock` sem consumidores reais** — Arena shell, Autônomos, Radar
   montam `AgenticPill` com padding/gradient **copiados** em vez do dock
   compartilhado (ou o dock ficou órfão após peels).
2. **Workspace** reconstroi HStack star+invite+`atlasAgenticPillChrome` à mão
   (`WorkspaceView+ChromeNewPill`) em vez de `AgenticPill` / `AgenticPillFace`.
3. **Home** (pós-015) e **Code grafo** têm paths próprios; Code mantém trailing
   clear/“mostrar tudo” — ok se usarem a **mesma** face chrome.
4. **Sheets ask** podem divergir em detents/drag/bg/corner se cada host
   redeclara presentation.

WAVE-005 design v3 nunca fechou compress ledger; residual **vivo**. Isto não é
token opacity — é o operador sentir **primos** da porta de intenção.

---

## Patamar

| Antes | Depois |
|---|---|
| Dock shared dead + host clones | Todos os ops docks = `AgenticAskDock` |
| Workspace hand-roll chrome | `AgenticPill` / Face canônico |
| Sheet presentation dialect | `.agenticAskSheetPresentation()` único |
| Code fork slots | Mesma máquina + trailing slots |

Δ = capacidade de intenção unificada (eixo transversal).

---

## Arquitetura

### Princípios

- **Casca only.** Packs ficam em `*AskContext` / hosts (WAVE-002).
- **Uma face:** `AgenticPill` = star + italic invite + chrome + optional trailing.
- **Um dock:** `AgenticAskDock` = fade + pad + pill (ops bottoms).
- **Uma sheet:** `.agenticAskSheetPresentation()` large / drag hidden / bg / corner 28.
- Home may open picker/free path (015) — still **AgenticPill** face.
- Code trailing clear/mostrar tudo **preserved** (WAVE-001).
- Hosts ≤400; zero god-file.

### Consumidores alvo

```
ArenaPremiumShell / Destination  → AgenticAskDock { AgenticPill }
AutonomosMapShell                → AgenticAskDock { AgenticPill }
AtlasCodeRadar*                  → AgenticAskDock { AgenticPill }
AtlasCodeView ask                → AgenticPill + trailing (dock or pad parity)
Home input                       → AgenticPill
Workspace new                    → AgenticPill / Face (NavigationLink OK)
```

### Fora de escopo

- Core packs tipados / NL mandar-fazer.
- Redesign invite copy only.
- Collapse ConversationView.
- Continuity / App Group.
- Nova área.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `AgenticAskDock.swift` / `AgenticPill.swift` | slots se preciso; keep craft |
| `ArenaPremiumShell.swift` / Destination | use dock + sheet |
| `AutonomosMapShell.swift` | use dock + sheet |
| Radar ask peels | use dock |
| `AtlasCodeView+AskPill*` | AgenticPill + trailing; pad parity |
| `WorkspaceView+ChromeNewPill*` | AgenticPill/Face |
| Home input / Root chrome face | AgenticPill if not already |
| A11yIDs | stable existing |

### W3

| Alvo | Estimativa |
|---|---|
| Delete dock clones + hand-rolls | **−150…−400** |

`WAVE-016-compress.md`.

---

## DoD (≥5)

1. Arena shell, Arena destination, Autônomos, Radar usam **`AgenticAskDock`**
   (fade/pad idênticos).
2. Home e Workspace renderizam via **`AgenticPill`/`AgenticPillFace`** (sem
   HStack star+chrome duplicado).
3. Code grafo usa mesma face chrome + trailing clear/mostrar tudo; âncora
   WAVE-001 **não regride**.
4. Sheets ask compartilham `.agenticAskSheetPresentation()` (ou delta mínimo
   documentado se host ConversationView diferente).
5. A11y IDs estáveis: home / workspace / code / radar / arena / autonomos.
6. Haptic medium no tap da pílula (paridade).
7. Gates guard + checks + build; hosts ≤400.

---

## Anti-objetivos

- Só unificar opacity modifier.
- Micro copy de invite.
- Collapse god-file.
- Mudar packs/turnFacts sem necessidade.
- Core edits.
- Nova área/tab.

---

## Plano W3

DoD consumers → delete dead dock clones → fuse micro peels criados → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — órgão de intenção |
| DoD≥5 + ≥3 superfícies | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Code trailing break anchor | critical if | preserve clear/legend |
| Dock dead again after fuse | major | rg consumers ≥4 |
| Workspace NavigationLink | major | Face not Button |

**Critical open:** 0.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- residual post-015 #1 pill-chrome-one-machine  
- live: AgenticAskDock zero consumers; Workspace hand-roll  
