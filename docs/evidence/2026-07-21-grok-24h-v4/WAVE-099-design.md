# WAVE-099 — change-review-governance-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-099-change-review-governance-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-013/C18–C21 governance blocks exist, mas **spoken do conselho**,
  stats line, hash warning e section diverge ainda são dialeto em
  `ChangeReviewGovernanceBody` (`ChangeReviewCouncilA11y` + strings).
- Risk Judgment (face/rank) não cobre governance chrome honesty.
- Residual pós-risk/patch/findings: governance organ incompleto.

## Patamar

| Antes | Depois |
|---|---|
| CouncilA11y soup | **ChangeReviewJudgment** governance spoken |
| Hash warning local | Judgment constant |
| Stats a11y local | spokenDiffStats |
| Pack risk only | pack governance facts optional |

Δ = **soberania do chrome de governança** na revisão de mudanças.

---

## Arquitetura

### Princípios

- Casca only. DiffStats/Council/Hash from published governance metadata.
- Don't re-open risk face product words wholesale.
- Zero Core.

### Fluxo

```
stats · council · hashMismatch?
  → ChangeReviewJudgment.spokenCouncilSection · spokenDiffStats
       · hashWarningLabel · packGovernanceFacts
  → GovernanceBody wire
```

### Arquivos

- `ChangeReviewJudgment.swift` (extend)
- `ChangeReviewGovernanceBody.swift`
- CODEMAP
- design/compress

### Densidade

Judgment +80–150 · Body thinner

### Fora de escopo

- Core governance decode  
- Tipografia  
- Fuse risk monólito rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] spokenCouncilSection from Judgment.
- [ ] spokenDiffStats from Judgment.
- [ ] hashWarningLabel from Judgment.
- [ ] Delete ChangeReviewCouncilA11y soup.
- [ ] packGovernanceFacts optional when metadata present.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar conselho  
- tipografia  

## Plano W3

1. Extend Judgment.  
2. Wire GovernanceBody.  
3. Delete A11y enum.  
4. CODEMAP.  
5. ~5 files · ~150–300 LOC.

## Proof

1. Diverged council spoken includes divergência.  
2. Stats a11y ≡ files/add/del.  
3. Hash warning VO constant.  
4. DEVICE_PENDING.

## Council

Residual after reason-098 + risk organ.

---

## Critérios de rejeição

Se B só renomear sem delete CouncilA11y + pack → fail.

---

*End WAVE-099 design.*
