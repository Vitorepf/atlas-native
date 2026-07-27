# WAVE-005 — agentic-pill-one-machine

**Status:** design approved  
**Wave:** `WAVE-005-agentic-pill-one-machine`  
**Date:** 2026-07-21  
**Owner:** casca only  

---

## Problema

A lei da pílula é **um chrome / um órgão**. Depois de WAVE-001–004:

- `AgenticPill` + `atlasAgenticPillChrome()` existem, mas **não são a máquina única**.
- **4 docks** copiados: Arena shell · Arena destination · Autônomos · Radar (fade + pad + pill).
- **Home / Workspace** reconstroem HStack star+invite+chrome.
- **Code grafo** mantém máquina paralela com slots (clear/âncora) em `AtlasCodeView+AskPill`.
- Sheets ask repetem detents/large, drag hidden, bg, corner 28.

Isto não é polish de token: o operador sente **primos** da pílula, não um órgão.

## Patamar

**Antes:** 4 docks + 3 hand-rolls + Code fork.  
**Depois:** surfaces só fornecem `invite · accessibilityId · action · optional trailing` (+ sheet open). Dock, glass, star, haptics e presentation sheet vivem **uma vez**.

Δ = capacidade de intenção unificada (eixo transversal), não um modifier isolado.

## Arquitetura

### Primitivos novos (casca)

```
AgenticPill              — body: star + invite + optional trailing; chrome; a11y
AgenticAskDock           — gradient veil + horizontal pad + bottom pad + AgenticPill
.agenticAskSheet { }     — detents large, drag hidden, bg Atlas, corner 28
```

### Slot API (Code)

```swift
AgenticPill(
  invite: …,
  accessibilityId: A11yID.codeAskPill,
  trailing: { askPillClearButton /* chevron optional */ },
  action: { showsAskCard = true }
)
```

Caption/anchor color stays host-owned when needed (Code may pass invite text = `anchorLegend ?? invite`).

### Packs

**Não reabrir WAVE-002.** Hosts continuam donos de `*AskContext` / turnFacts. Esta onda é chrome/dock/sheet only.

### Fora de escopo

- Core packs tipados, NL write, tool_permissions  
- Failure-empty canon (WAVE-006 candidate)  
- Autônomos organism truth (WAVE-007 candidate)  
- SuiteSheet (WAVE-00N)

## Arquivos

| Path | Mudança |
|---|---|
| `App/Atlas/AgenticPill.swift` | expand slots (trailing); keep typealias |
| `App/Atlas/AgenticAskDock.swift` | **new** shared dock |
| `App/Atlas/AgenticAskSheet.swift` or View extension | **new** presentation modifier |
| `App/Atlas/ArenaPremiumShell.swift` | use AgenticAskDock + sheet modifier |
| `App/Atlas/ArenaPremiumDestinationView.swift` | same (no inline dock) |
| `App/Atlas/AutonomosMapShell.swift` | same |
| `App/Atlas/AtlasCodeRadarView+AskPill.swift` | same |
| `App/Atlas/RootView+InputBarContent.swift` (+ related) | Home → AgenticPill |
| `App/Atlas/WorkspaceView+ChromeNewPill.swift` | Workspace → AgenticPill |
| `App/Atlas/AtlasCodeView+AskPill.swift` | Code → AgenticPill + trailing slots |
| A11yIDs | only if new shared id needed — prefer existing |

**W3:** delete dead dock private vars; fuse any micro peels created; no host >400.

## DoD (≥5 — observável)

1. **Arena shell, Arena destination, Autônomos, Radar** usam o **mesmo** `AgenticAskDock` (fade height, padding, pill contract idênticos).
2. **Home e Workspace** renderizam via `AgenticPill` (sem HStack star+chrome duplicado).
3. **Code grafo** usa a mesma máquina chrome + trailing clear/“mostrar tudo”; âncora WAVE-001 (legend → emptyPrompt) **não regride**.
4. **Sheet ask** compartilha presentation (detents/large, drag hidden, bg, corner 28) em Arena/Autônomos/Radar (Code sheet path alinha ou documenta delta mínimo se ConversationView host diferente).
5. **A11y IDs estáveis:** `home-input-pill` / workspace new / `code-ask-pill` / `code-radar-ask-pill` / arena premium / autonomos — sem quebrar XCUITest identifiers existentes.
6. Haptic medium no tap da pílula (paridade com AgenticPill atual).
7. Gates: `./scripts/grok-god-wave-guard.sh` · `swift run AtlasCoreChecks` · `cd App && make build`; nenhum `*View*/*Shell*` >400.

## Anti-objetivos

- “Só unificar opacity/chrome modifier” (já existe).  
- Micro copy de invite.  
- Collapse into god-file.  
- Mudar packs/turnFacts sem necessidade.  
- Core edits.  
- Nova área/tab/rota.

## Plano W3 (ΔLOC alvo)

| Alvo | Estimativa |
|---|---|
| Delete 4 dock clones + 2 hand-rolls | −150…−300 |
| Code AskPill simplify | −50…−100 |
| **Meta líquida** | **−250…−700** honest (DoD/hosts pass §B even if &lt;800) |

Report `git diff --numstat` in `WAVE-005-compress.md`.

## Gates

```bash
./scripts/grok-god-wave-guard.sh
swift run AtlasCoreChecks
cd App && make build
```

Commits: `feat(ui): WAVE-005 …` only in W2/W3.

## Reviewer (self · 0 critical)

| Issue | Sev | Resolution |
|---|---|---|
| Code slots break anchor | critical if ship | Preserve clear + legend wiring tests via structure |
| Destination dock drift | major | Must call shared AgenticAskDock |
| Sheet modifier fights NavigationStack | major | Apply at sheet content, not whole nav |
| Home craft loss (star/italic) | major | AgenticPill already is Home craft |

**Critical open:** 0.

## Approval

- [x] §B pass (patamar + ≥3 hosts + DoD≥5 + casca + anti-micro)  
- [x] Sections complete  
- [x] design_approved when ledger flips after this file on disk  
