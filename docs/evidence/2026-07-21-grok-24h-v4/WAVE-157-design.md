# WAVE-157 — arena-occasion-organ-pack-wire-instrument

**Status:** design · proposed  
**Wave:** `WAVE-157-arena-occasion-organ-pack-wire-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 · anti density-peel)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-083 fechou **can_do** Arena; WAVE-108/109 fecharam **Stop** e
  **Pipeline** Judgment na UI; WAVE-107 **RunStatus** na lista/detail.
  **packFacts dessas APIs existem e não são chamados** por
  `ArenaPremiumAskContext` (rg: zero call sites fora das defs):
  - `ArenaStopJudgment.packFacts`
  - `ArenaPipelineJudgment.packFacts`
  - `ArenaStartJudgment.packFacts`
  - `ArenaRunStatusJudgment.packFacts`
- AskContext ainda embute status de corrida com
  `run.status.displayPT` / LiveControl `rawValue` enquanto a UI usa
  `ArenaRunStatusJudgment.label/productWord` → **triple dialect**.
- Frota: UI rankeia em `ArenaPremiumFleetView` (sort ad hoc); pack
  `composite.engines.prefix(8)` em **wire order** → pílula ≠ “onde o
  Atlas sobe”.
- Pílula pode alegar `cta_only_run_stop` sem facts de governança de
  stop/pipeline/start — **mentira por omissão** no pack (mesmo padrão
  hollow-wire que maxeou 095/106 na conversa).
- **Não** é density peel (WAVE-156 med). É wire de soberania do pack.

## Patamar

| Antes | Depois |
|---|---|
| packFacts Stop/Pipeline/Start/RunStatus mortos | AskContext **wire** organs publicados |
| status raw/displayPT no pack | **RunStatusJudgment** productWord one law |
| fleet pack wire order | fleet rank ≡ FleetView (Score/Fleet Judgment) |
| can_do stop sem órgãos | facts ≡ face (stop ready · pipeline · start receipt) |
| ≤5s ask Arena world incomplete | Pack completa o que a face já julga |

Δ = **soberania do pack Arena** — Judgment organs deixam de ser UI-only.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Só chamar packFacts já existentes; opcional thin
  `ArenaFleetJudgment.rank` extract do sort da FleetView.
- **Honesty:** never invent stop receipt / pipeline marks / engines.
- **083 pétreo:** can_do matrix stays; complete fact organs around it.
- **One domain:** Arena occasion pack wire (not shell peels).
- Stop sheet open: wire packFacts when stoppable **or** honest absence
  `stop_sheet: face-only` if modal unbound — prefer wire when `canStop`.

### Fluxo / layout alvo

```
ArenaPremiumAskContext.facts(tab, destination, model)
  → existing Now + LiveControl pack (keep)
  → live rows: status via ArenaRunStatusJudgment.productWord/label
  → if execution/now live:
       + ArenaPipelineJudgment.packFacts(project(...))
  → if canStop / stop context:
       + ArenaStopJudgment.packFacts(actor?, reason?, receipt?, error?)
  → if start receipt / run sheet:
       + ArenaStartJudgment.packFacts(...)
  → if fleet tab:
       engines = ArenaFleetJudgment.rank(composite.engines) // extract
       pack top by rank (not wire prefix)
  → can_do unchanged law 083
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| Extend AskContext | wire packFacts + status dialect |
| Optional `ArenaFleetJudgment` | rank · best · packFleet (from FleetView sort) |
| Existing Stop/Pipeline/Start/RunStatus | packFacts callers |

### Arquivos prováveis

- `ArenaPremiumAskContext.swift`
- `ArenaPremiumFleetView.swift` — consume FleetJudgment.rank
- Optional `ArenaFleetJudgment.swift` (**new** pure)
- `ArenaLiveControlJudgment.swift` — only if status pack line moves
- `ArenaStopJudgment` / `ArenaPipelineJudgment` / `ArenaStartJudgment` /
  `ArenaRunStatusJudgment` — no logic invent, wire only
- CODEMAP (B)

### Densidade

- AskContext grows wire, not monólito multi-tab chrome peel
- FleetJudgment **150–400** if extracted

### Fora de escopo

- WAVE-156 density peels  
- Core Arena APIs  
- Typography / fuse-as-WAVE  
- Redesign Stop sheet chrome  
- Re-open Now phase UI  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] rg shows callers of Stop/Pipeline/Start/RunStatus **packFacts** from AskContext.
- [ ] Live run lines in pack use RunStatusJudgment product words (not raw-only).
- [ ] Fleet pack order ≡ FleetView rank when engines published.
- [ ] canStop true → stop organ facts or explicit absence if sheet unbound.
- [ ] Pipeline visible on execution → pipeline packFacts present.
- [ ] No invented engines/receipts.
- [ ] Gates + CODEMAP arena organ pack wire (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- density peel multi-host  
- tipografia  
- invent pack counts  
- fuse Fleet+Results monólito  

## Plano W3

1. Wire packFacts in AskContext by tab/destination.  
2. Unify status productWord.  
3. Extract Fleet rank Judgment + pack.  
4. rg dead packFacts APIs.  
5. CODEMAP (B).  
6. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. Live stoppable → pack has stop/can_stop organ facts.  
2. Execution with pipeline → pack pipeline marks.  
3. Fleet tab → top engine matches UI “best”.  
4. Quiet browse → readChat + no fake stop organs.  
5. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Sovereignty:** #1 residual max = Arena Judgment packFacts hollow after
UI campaign 107–109.  
**Autônomos veto pack** / **Home can_do hardcode** = WAVE-158.  
**WAVE-156 density peel** = reject as product ranking (med structure only).

### Runner-ups

1. autonomos-selfconstruction-veto-pack-and-can-do  
2. home-workspace-radar-can-do-pack-honesty  
3. conversation-strip-stop-pack-honesty + steer packFacts  
4. autonomos receipt tone structured applied  

---

*End WAVE-157 design.*
