# WAVE-190 — autonomos-catalog-list-pack-and-hub-receipt-tone

**Status:** design · proposed  
**Wave:** `WAVE-190-autonomos-catalog-list-pack-and-hub-receipt-tone`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

### A — Catálogo Autônomos pack mente vazio

- Face catálogo: `AutonomosMapShellCatalog` passa
  `model.operatorUnits` reais à lista (WAVE-090 judgment rank).
- Pack ask: quando `unit == nil`, `AutonomosAskContext` chama
  `AutonomosListJudgment.packFacts(units: [], awaitingUnitIDs: [])`
  **sempre** — absences tipo “catálogo vazio neste iPhone” enquanto a
  tela mostra units.
- Ask host (`AutonomosMapShellAsk`) **nunca** passa units/awaitingIDs
  para `facts(...)` — hollow wire, não ausência de API.
- **UI ≠ pack** na porta frota: agent inventa “não há Autônomos” ou
  ignora o catálogo visível.

### B — Hub receipt tone ignora `controlApplied` estruturado

- `AutonomosHubJudgment.receiptTone(line:controlApplied:)` prefer
  `controlApplied == false` → `.error`; pack destination já passa
  `lastControlReceipt?.applied`.
- Hub face: `receiptTone(line: controlReceiptLine)` **só** — lexical
  `["não","erro",…]` sem bit `applied`.
- `applied == false` sem marcador lexical → chrome pode pintar `.ok`
  enquanto pack diz `hub_control_applied: no`.

## Patamar

| Antes | Depois |
|---|---|
| packFacts(units: []) no catálogo | packFacts(**operatorUnits** · awaitingIDs reais) |
| Ask host sem units | MapShellAsk passa model catalog slice |
| Hub tone lexical only | Hub tone **controlApplied** structured |
| ≤5s pack mente vazio | Pack ≡ lista; recibo face ≡ pack |

Δ = **soberania catálogo + recibo de controle** Autônomos.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `operatorUnits`, `awaitingUnitIDs` (DecisionJudgment),
  `lastControlReceipt.applied` already published.
- **Honesty:** empty real catalog → empty face; never invent units.
- **WAVE-090/184 pétreos:** list rank + unit focus stay; fix **wire**.
- One domain: Autônomos catalog pack + hub receipt face (same vertical).

### Fluxo / layout alvo

```
AutonomosMapShellAsk turnFacts
  → AutonomosAskContext.facts(
       unit: nil,
       units: model.operatorUnits,
       awaitingUnitIDs: DecisionJudgment.awaitingUnitIDs(...),
       lastControlReceipt: model.lastControlReceipt,
       ...
     )
  → when unit==nil: packFacts(units: real, awaiting: real)

HubView
  → receiptTone(line:, controlApplied: lastApplied)
  → MapShellRoutes pass applied bit
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| AutonomosAskContext signature | units + awaiting params |
| AutonomosListJudgment | already packFacts — wire only |
| HubView / MapShellRoutes | controlApplied face |

### Arquivos prováveis

- `AutonomosAskContext.swift`
- `AutonomosMapShellAsk.swift`
- `AutonomosListJudgment.swift` (if pack needs awaiting rank facts)
- `AutonomosHubView.swift`
- `AutonomosMapShellRoutes.swift` / MapShell host
- CODEMAP (B)

### Densidade

- Thin wire; no monólito peel

### Fora de escopo

- Density peels  
- Create server units  
- Core  
- Typography  
- Destination pack (188 owns tela/foco)  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Catalog ask with N units → packFacts count N (not empty absence).
- [ ] Zero units real → honest empty (not false full).
- [ ] awaitingUnitIDs when backlog signals hydrate (if published).
- [ ] Hub receiptTone receives controlApplied from lastControlReceipt.
- [ ] applied false without lexical “erro” still error/not-ok tone.
- [ ] Pack hub_control_applied still aligned face.
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- invent units  
- density peel  
- tipografia  
- reabrir 090 rank law  

## Plano W3

1. Extend AskContext.facts units/awaiting.  
2. Wire MapShellAsk.  
3. Hub controlApplied face.  
4. rg packFacts(units: []).  
5. CODEMAP (B).  
6. Estimativa: **~5–8 files · ~250–450 LOC**.

## Proof / device

1. 2+ operator units, no unit open → pack lists catalog face not empty.  
2. Control not applied → hub tone error/not-ok without relying on “não” only.  
3. Empty catalog real → empty honesty.  
4. DEVICE_PENDING se passcode.

## Council

**Pack hollow:** Autônomos catalog units:[] hardcode = max face≠pack.  
**Hub controlApplied** face incomplete = same vertical fold.  
**Queue row can_do** = WAVE-189.  
**WAVE-188** open high keep.

### Runner-ups

1. conversation-live-control-strip-card-unify  
2. ChangeReviewControl face labels dual  
3. AutonomosRunControl primaryAction pack verbs  

---

*End WAVE-190 design.*
