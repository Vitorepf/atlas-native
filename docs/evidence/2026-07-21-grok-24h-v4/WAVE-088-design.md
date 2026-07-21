# WAVE-088 — autonomos-can-do-pack-honesty-instrument

**Status:** design · proposed  
**Wave:** `WAVE-088-autonomos-can-do-pack-honesty-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · residual after 087 · A runner-up)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Arena WAVE-083 owns honest `can_do` matrix from live face.
  Autônomos pack still hardcodes `canDo: .faceCTALocal` always in
  `AutonomosAskContext.facts` — even when catalog is empty, incident
  is read-only, or control face is unbound / unregistered.
- Operators get pack lying that face CTAs are available when
  `canControl=false` or destination is pure read (evolution/moment).
- Residual after multi-area bind 065 / transfer / run control organs.

## Patamar

| Antes | Depois |
|---|---|
| Always faceCTALocal | **matrix** destination × controlFace × canControl |
| No pack can_do fact line | pack `can_do` + absences honesty |
| Decisions always CTA | faceCTA only when decisions published |
| Unbound catalog CTA claim | readChat / statusOnly honesty |

Δ = **soberania can_do Autônomos** — pack não mente sobre write/CTA.

---

## Arquitetura

### Princípios

- Casca only. Use published controlFace, canControl, destination, decisionCount.
- Honesty: NL never tool write; CTA only when face actually has controls.
- Mirror Arena 083 pattern; don't invent Core can_do.
- Zero Core.

### Fluxo

```
destination? + controlFace + canControl + decisionCount
  → AutonomosCanDoJudgment.occasionCanDo
       readChat | statusOnly | faceCTALocal | ctaOnlyRunStop
  → packFacts can_do line + absences
  → AutonomosAskContext.facts wire
```

### Matrix (product)

| Condição | can_do |
|---|---|
| canControl && face run/stoppable (live/pause arms) | ctaOnlyRunStop or faceCTALocal per face |
| decisions destination + decisionCount > 0 | faceCTALocal |
| evolution / moment / incident without control | readChat |
| catalog nil unit + unbound | statusOnly or readChat |
| canControl=false always demote from CTA write | readChat + absence |

### Arquivos

- `AutonomosCanDoJudgment.swift` (**new**)
- `AutonomosAskContext.swift`
- optional destination helpers
- CODEMAP
- design/compress

### Densidade

Judgment 120–280

### Fora de escopo

- Core run control API  
- New destinations  
- Arena rework  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Exclusive can_do product from Judgment matrix (not always faceCTALocal).
- [ ] canControl=false never claims face write CTA.
- [ ] Decisions destination with zero decisions → readChat honesty.
- [ ] Evolution/moment default readChat.
- [ ] Pack facts include can_do + demotion absences.
- [ ] AskContext wires Judgment only.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar canControl  
- fundir RunControl monólito  
- reabrir Arena 083  

## Plano W3

1. Judgment matrix + packFacts.  
2. Wire AskContext.  
3. CODEMAP.  
4. ~5 files · ~200–350 LOC.

## Proof

1. Open Autônomos catalog → can_do read/status not false CTA.  
2. Live unit with canControl → faceCTALocal / ctaOnly.  
3. Decisions empty → no face CTA claim.  
4. DEVICE_PENDING.

## Council

Runner-up after worktrees-087.

---

*End WAVE-088 design.*
