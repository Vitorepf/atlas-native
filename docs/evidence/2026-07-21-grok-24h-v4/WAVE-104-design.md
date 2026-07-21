# WAVE-104 — autonomos-home-residual-spoken-judgment

**Status:** design · proposed  
**Wave:** `WAVE-104-autonomos-home-residual-spoken-judgment`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia · zero A11y enums)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Residual `accessibilityLabel("…")` em **Autônomos** (Digest, Evolution,
  Map self-build CTA, Decision face) e **perfil Home** ainda interpolam
  localmente fora dos Judgments.
- Pós wipe de enums A11y: dialeto interpolado é o residual de soberania.
- Operador de frota/perfil escuta labels sem helpers de órgão.

## Patamar

| Antes | Depois |
|---|---|
| Digest title,meta local | DigestJudgment.spokenRow |
| Evolution marco local | EvolutionJudgment.spokenMarco |
| Map self-build CTA string | HubJudgment.selfBuildReceiptSpoken |
| Decision face.heroSub join | DecisionJudgment.spokenFaceChrome |
| Profile operator/line | HomeOpsJudgment profile spoken |

Δ = **fecha residual de spoken Autônomos + Home profile** nos órgãos.

---

## Arquitetura

### Princípios

- Casca only. Titles/meta from published models.
- No new domain. Extend existing Judgments.
- Zero Core.

### Fluxo

```
title/meta/marco/face/profile fields
  → *Judgment.spoken*
  → Views wire only
```

### Arquivos (≥5)

1. AutonomosDigestJudgment  
2. AutonomosEvolutionJudgment  
3. AutonomosHubJudgment (or Map)  
4. AutonomosDecisionJudgment  
5. HomeOpsJudgment  
6. DigestSurface · EvolutionView · MapShell · DecisionSurface · ProfileSheet  
7. CODEMAP · design · compress  

### Densidade

+10–30 per Judgment · thinner views

### Fora de escopo

- Core profile fields  
- Tipografia  
- New Autônomos routes  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] DigestJudgment.spokenRow(title,meta)  
- [ ] EvolutionJudgment.spokenMarco  
- [ ] HubJudgment self-build receipt spoken constant  
- [ ] DecisionJudgment.spokenFaceChrome  
- [ ] HomeOpsJudgment operator + profileLine spoken  
- [ ] All residual Autônomos/profile interpolations wire Judgment  
- [ ] Gates + CODEMAP + DEVICE_PENDING  

## Anti-objetivos

- inventar nome do operador  
- tipografia  

## Plano W3

1. Extend 5 Judgments.  
2. Wire 5 views.  
3. CODEMAP.  
4. Gates.  

## Proof

1. Digest row VO = title, meta.  
2. Evolution marco VO = title, meta.  
3. Map CTA fixed spoken.  
4. Decision face combines face + heroSub.  
5. Profile "Vitor, operador do Atlas" from Judgment constant.  
6. DEVICE_PENDING.

## Council

After zero A11y enums. Residual dialect interpolations only.

### Rejection

If B only touches one surface → fail (need Autônomos + Home).

### Why full-bar

- ≥5 Judgment + ≥5 views · product residual multi-surface  
- design ≥120 · DoD ≥5  

---

*End WAVE-104 design.*
