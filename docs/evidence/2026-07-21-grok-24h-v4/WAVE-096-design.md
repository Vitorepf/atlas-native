# WAVE-096 — autonomos-hub-face-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-096-autonomos-hub-face-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-007 vestment + 030 run control + 088 can_do exist.
  O **hub de um Autônomo** ainda compõe spoken/kicker/receipt tone
  localmente em `AutonomosHubView` (`hubSpokenLabel`, kickerLine,
  receipt color via string contains "erro"/"falha").
- Receipt tone é dialeto frágil (substring PT); control/transfer receipts
  já têm Judgment line builders mas hub não julga face de hub.
- Residual pós-list-090 / can_do-088: hub surface pack/spoken organ.

## Patamar

| Antes | Depois |
|---|---|
| hubSpoken local | **AutonomosHubJudgment** spokenHub |
| Receipt color string soup | receiptTone face |
| Kicker string local | Judgment kicker |
| Pack só via AskContext | hub packFacts optional |

Δ = **soberania do hub Autônomo** — presença/verbos/recibos uma língua.

---

## Arquitetura

### Princípios

- Casca only. Vestment/controlFace/receipts already published.
- Don't rewrite RunControl/Transfer judgments — compose.
- Zero Core.

### Fluxo

```
unit + vestment + controlFace + receipts + needsBind
  → AutonomosHubJudgment
       hubFace · spokenHub · kicker · receiptTone
       packFacts
  → AutonomosHubView wire
```

### Arquivos

- `AutonomosHubJudgment.swift` (**new**)
- `AutonomosHubView.swift`
- CODEMAP
- design/compress

### Densidade

Judgment 120–280

### Fora de escopo

- Map shell routes  
- Create Autônomo  
- Core loop APIs  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] hubFace product words (awaiting/live/quiet/needs_bind).
- [ ] spokenHub from Judgment.
- [ ] kickerLine from Judgment.
- [ ] receiptTone ok|error without fragile substring only (structured).
- [ ] Pack hub_face facts.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar control face  
- tipografia  
- fuse list+hub monólito  

## Plano W3

1. Judgment.  
2. Wire HubView.  
3. CODEMAP.  
4. ~5 files · ~200–350 LOC.

## Proof

1. Awaiting hub spoken includes vestment + control.  
2. Error receipt → error tone.  
3. needsBind face.  
4. DEVICE_PENDING.

## Council

Runner-up after can_do surfaces closed.

---

## Hub faces

| Face | Quando |
|---|---|
| needs_bind | needsAreaBind |
| awaiting | vestment.awaiting |
| live | vestment.live |
| quiet | vestment.quiet |

Receipt tone: error if line contains structured failure markers OR explicit
flag from control receipt applied=false (prefer structured when available).

## Critérios de rejeição

Se B só mover hubSpoken string sem face/pack → fail.

---

*End WAVE-096 design.*
