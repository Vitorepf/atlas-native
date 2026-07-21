# WAVE-094 — arena-capabilities-confidence-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-094-arena-capabilities-confidence-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Aba **Capacidades** da Arena ainda **julga confiança na View**:
  `measuredCount` / improved / regressed private em
  `ArenaPremiumCapabilitiesView` (`confidenceLevel == .measured`,
  Newcombe significant deltas).
- **Pack dual dialect:** `ArenaPremiumAskContext` capabilities branch conta
  `covered = caps.filter { score != nil || withAtlas != nil }` →
  `"capacidades: N cobertas"` — presença de score ≠ confidence measured.
  Comentário no UI: survival numbers sold as victory.
- Spoken row / `shortConfidence` / delta color / empty editorial = View
  dialect; `ArenaScoreJudgment` só dá kicker genérico.
- Pós-083 can_do live e 085 plan/queue: residual **capabilities number
  honesty** — operador e pílula contam mundos diferentes.

## Patamar

| Antes | Depois |
|---|---|
| measured law na View | **ArenaCapabilitiesJudgment** one law |
| Pack “cobertas” = score presence | Pack = measured/improved/regressed counts |
| Rank ad hoc | regressed-first · low-confidence attention |
| shortConfidence local | Judgment spoken/shortConfidence |
| ≤5s números mentem | UI ≡ pack confidence |

Δ = **soberania dos números de capacidade** — não vender score presence
como medido.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `AtlasArenaCapability` confidenceLevel + delta published.
- **Honesty:** score presence ≠ measured; unmeasured silence; never invent
  significance.
- **One domain:** capabilities organ (not fleet/results monólito).
- Pack law: facts from Judgment counts; absences when empty/unmeasured.
- WAVE-021 scoreboard pétreo for engines; this is capabilities tab.

### Fluxo / layout alvo

```
capabilities[]
  → ArenaCapabilitiesJudgment
       face: empty | list(n)
       measured / improved / regressed / stable counts (one law)
       rank: regressed-first then low confidence
       shortConfidence · spokenRow · packFacts
  → CapabilitiesView peels
  → AskContext capabilities branch uses Judgment (never score-presence cobertas)
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `ArenaCapabilitiesJudgment` | face · counts · rank · spoken · pack |
| CapabilitiesView | wire |
| AskContext | pack honesty |

### Arquivos prováveis

- `ArenaCapabilitiesJudgment.swift` (**new**)
- `ArenaPremiumCapabilitiesView.swift`
- `ArenaPremiumAskContext.swift`
- Optional `ArenaPremiumCapabilityDetail.swift` if caption repeats
- CODEMAP (B)

### Densidade

- Judgment **200–600**
- View shrinks private math

### Fora de escopo

- Core capability contracts  
- Results/Fleet fuse  
- ScoreJudgment composite rewrite  
- Pipeline destination  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Exclusive face empty|list + product words.
- [ ] measured/improved/regressed counts **one law** UI+pack.
- [ ] Pack never uses score-presence as “cobertas medido”.
- [ ] Rank regressed-first (or documented attention order).
- [ ] shortConfidence/spoken from Judgment.
- [ ] Empty capabilities silence honest.
- [ ] Gates + CODEMAP (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar significance  
- tipografia  
- fuse Capabilities+Results monólito  
- reabrir ScoreJudgment engines wholesale  

## Plano W3

1. Extract measured law + rank → Judgment.  
2. Wire CapabilitiesView.  
3. Wire AskContext pack.  
4. Delete dual “cobertas” path (rg).  
5. CODEMAP (B).  
6. Estimativa: **~5–8 files · ~300–550 LOC**.

## Proof / device

1. Caps with scores but unmeasured confidence → pack not “N cobertas” victory.  
2. Significant regressed → ranks first; pack regressed count.  
3. Empty list → empty face.  
4. UI counts ≡ pack counts.  
5. DEVICE_PENDING se passcode.

## Council

**Arena/Código:** #2 residual max = capabilities confidence pack/UI lie.  
**093** owns conversation can_do.  
**Run status shared** / receipt tone = runners-up.

### Runner-ups

1. arena-run-status-shared-judgment  
2. conversation-live-control-cta-judgment  
3. autonomos-control-receipt-tone  
4. composer-attachments-source-judgment  

---

*End WAVE-094 design.*
