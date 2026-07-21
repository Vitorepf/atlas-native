# WAVE-176 — search-agentic-pack-and-pill-host

**Status:** design · proposed  
**Wave:** `WAVE-176-search-agentic-pack-and-pill-host`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Lei da pílula (`atlas-native-agentic-pill.md`): **toda superfície operacional**
  carrega pílula + pack compilado. Arena sem pílula = falha de produto.
- **Search** é porta operacional (abrir conversa, achar thread) e ainda é
  **chrome-only**: `SearchView` / surface **sem** `AgenticPill` /
  `turnFacts` / AskContext.
- `SearchScreenJudgment.packFacts` + `SearchListJudgment.packFacts` **já
  existem** e formam chain morta (screen → list) — **zero** wire em ask
  host (WAVE-170 deferred Search as “host-blocked” — **that is the gap**).
- Home/Workspace/Code/Radar/Arena/Autônomos/Conversation already have
  partida or organ packs. Search is the last major door without agentic
  entry.
- Operador ≤5s: “abre X / o que há de recente?” with **screen face ≡ pack**
  (loading/offline/empty/results), not blind NL.

## Patamar

| Antes | Depois |
|---|---|
| Search sem pílula | **AgenticAskDock + SearchAskContext** |
| packFacts Judgment mortos | wire SearchScreenJudgment.packFacts |
| can_do inexistente | Partida-style readChat + absences nav |
| Agent cego na busca | Pack = query · face · counts · live rank honesty |
| ≤5s search world missing | Search na era agêntica |

Δ = **soberania da porta Search** — fecha o buraco da pílula.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** SearchScreenJudgment already pure from session phase /
  query / counts.
- **Honesty:** never invent threads; empty/offline faces silence.
- **can_do:** readChat + absences “abrir thread é nav; NL não para run”
  (PartidaCanDoJudgment.search helper optional).
- **WAVE-032/089** live-first list rank stays; pack uses list organ.
- Pack never on pill face chrome (016).
- One domain: Search ask host.

### Fluxo / layout alvo

```
SearchView
  → safeAreaInset AgenticAskDock {
       AgenticPill(invite: SearchAskContext.invite) { sheet }
     }
  → ConversationView turnFacts: SearchAskContext.facts(
       session, query, loading, offline, recentCount, resultCount, live)
  → SearchScreenJudgment.packFacts(...) // includes list
  → canDo PartidaCanDoJudgment.search(...) or readChat + absences
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `SearchAskContext` (**new**) | invite · empty · facts · can_do |
| SearchScreenJudgment | wire packFacts (exists) |
| SearchView / Surface | pill dock |

### Arquivos prováveis

- `SearchAskContext.swift` (**new**)
- `SearchView.swift` / `SearchSurface.swift`
- `SearchScreenJudgment.swift` — no invent, wire only
- `PartidaCanDoJudgment.swift` — optional search()
- `RootChromeConversationRoutes.swift` — only if route hosts need dock
- A11yIDs search pill
- CODEMAP (B)

### Densidade

- AskContext **150–400**
- View stays thin dock

### Fora de escopo

- Core search API  
- Invent ranking  
- Density peels  
- Typography  
- Fake write can_do  
- Timeline host  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Search surface shows AgenticPill (or AskDock).
- [ ] turnFacts calls SearchScreenJudgment.packFacts (rg callers).
- [ ] loading/offline/empty/results faces in pack match screen.
- [ ] can_do honest read/nav; no stop invent.
- [ ] Live-first list honesty if live in results (optional fact).
- [ ] invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts WAVE-002 law when empty.
- [ ] Gates + CODEMAP search pack (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- density peel  
- invent threads  
- tipografia  
- re-rank search Core  

## Plano W3

1. SearchAskContext.  
2. Wire Judgment packFacts.  
3. Dock pill on SearchView.  
4. can_do partida search.  
5. CODEMAP (B).  
6. Estimativa: **~6–9 files · ~300–550 LOC**.

## Proof / device

1. Open Search → pill present.  
2. Empty/offline → pack face matches.  
3. Results → pack counts honest.  
4. Ask “o que estou vendo?” → agent uses search occasion.  
5. DEVICE_PENDING se passcode.

## Council

**Pill law:** Search last ops door without pack — max product.  
**Change-review assinatura pack** = WAVE-175.  
**Strip/StateCard dual** runner-up.

### Runner-ups

1. conversation-live-control-strip-card-unify  
2. composer-send-face-pack  
3. composer-queue-row-action-judgment  
4. autonomos hub controlApplied face  

---

*End WAVE-176 design.*
