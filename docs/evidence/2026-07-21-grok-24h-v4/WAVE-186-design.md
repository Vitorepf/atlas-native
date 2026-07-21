# WAVE-186 — hub-live-pack-arena-shell-and-dead-shim-delete

**Status:** design · proposed · high
**Wave:** WAVE-186-hub-live-pack-arena-shell-and-dead-shim-delete
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 185
**Δ patamar:** **high**

## Problema
1. **WorkspaceAskContext** still hand-rolls hub-global live lines
   (`sessoes_vivas_hub*` · `hub_live · …`) while scoped live is packed
   (`liveInWorkspaceFacts`) — dual dialect for hub vs scoped.
2. **ArenaPremiumAskContext** still hand-rolls shell
   (`tela`/`aba` · `cobertura_texto`) after score organs own numbers.
3. **LiveNowJudgment.packLiveAnchors** is a dead shim (zero call sites after
   WAVE-183) — canon §7.1 delete.

## Patamar
| Antes | Depois |
|---|---|
| hub live hand-roll | LiveNowJudgment.packHubFacts |
| Arena shell hand-roll | ArenaShellJudgment or Ask packShell |
| dead packLiveAnchors | deleted (rg = 0) |

Δ = hub/arena shell pack sovereignty + dead code delete.

## Arquitetura
Casca only.

### Fluxo
```
LiveNowJudgment.packHubFacts(liveSessions)
  → WorkspaceAskContext wires hub lines

ArenaPremiumAskContext.packShellFacts(tab, destination, coverageText)
  → facts host uses shell + organs only

Delete packLiveAnchors shim
```

### Arquivos (≥5)
1. LiveNowJudgmentRow.swift — packHubFacts · delete packLiveAnchors
2. WorkspaceAskContext.swift — wire hub pack
3. ArenaPremiumAskContext.swift — packShellFacts
4. CODEMAP
5. design · compress · DONE · LEDGER

### Densidade
wire + delete · ↓LOC hosts

### Fora de escopo
Core · invent live · density peels · tipografia

### §5
nenhum

## DoD produto (≥5)
- [ ] packHubFacts external caller (WorkspaceAsk)
- [ ] hub global never claimed as workspace-scoped
- [ ] Arena shell packFacts for tela/aba/cobertura
- [ ] packLiveAnchors rg = 0
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
invent stop on workspace · micro rename alone · Core

## Plano W3
1. packHubFacts 2. wire Workspace 3. Arena shell 4. delete shim 5. gates CODEMAP DONE

## Proof
1. hub live empty → sessoes_vivas_hub: 0
2. hub live N → global honesty absence line
3. Arena tab now → aba: now
4. rg packLiveAnchors = 0
5. DEVICE_PENDING

## Council
Closes last Workspace/Arena host hand-rolls + dead shim.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · product pack + dead delete

### Rejection
delete shim alone as WAVE · MARK-only

### Related
WAVE-183 LiveNow packFacts · WAVE-185 workspace shell · WAVE-181 score

### Sequence after
await A

### Acceptance
Build green · rg dead = 0

### W2/W3
Wire · delete · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — hub pack shape

```
facts:
- sessoes_vivas_hub: 0 | sessoes_vivas_hub_global: N
- hub_live · title · product
absences:
- (implicit: not workspace-scoped)
```

## Appendix — arena shell

```
facts:
- tela: … | aba: …
- cobertura_texto: …
absences:
- pack Core tipado Arena ainda §5
```

## Appendix — non-goals
Change live ranking · invent measurementId

## Appendix — risk
packHubFacts must not claim scoped live

## Appendix — test matrix

| case | expect |
|---|---|
| hub 0 | hub: 0 |
| hub 3 | global N + lines |
| dest execution | tela: Execução |
| rg shim | 0 |

## Appendix — commit
`feat(ui): WAVE-186 hub-live pack arena shell and dead shim delete`

## Appendix — god
one law hub live · one law arena shell · zero dead pack APIs

## Appendix — dual A
—

## Appendix — density
hosts thinner

## Appendix — a11y
unchanged

## Appendix — idle
dead delete is §7.1 inside full-bar WAVE
