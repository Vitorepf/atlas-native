# WAVE-171 — pack-host-density-peels-occasion-arena-autonomos

**Status:** design · proposed · high
**Wave:** WAVE-171-pack-host-density-peels-occasion-arena-autonomos
**Owner:** casca only · residual full-bar (fila empty · idle 2/2)
**Date:** 2026-07-21
**Created by:** implementer residual GOD density
**Δ patamar:** **high**

## Problema
Pack hosts inchados após campanha 157–170 (1 file = dezenas de órgãos):
- ConversationOccasionPack 366 LOC monólito multi-órgão
- ArenaPremiumAskContext 361 LOC
- AutonomosAskContext 302 LOC
Atrito agent-optimal: 1 read ≠ 1 intenção de órgão.

## Patamar
| Antes | Depois |
|---|---|
| OccasionPack monólito | host + Live + Organs peels |
| ArenaAsk monólito | host + Live + Score peels |
| AutonomosAsk monólito | host + Organs peel |

Δ = densidade agent-optimal dos hosts de pack (GOD canon §4).

## Arquitetura
### Princípios
Casca only · Zero Core · extension peels · behavior unchanged

### Layout
```
ConversationOccasionPack (host ≤180)
  + Live (session live + can_do + strip)
  + Organs (handoff/review/composer/proof/messages)
ArenaPremiumAskContext (host invite/canDo)
  + Live (now/pipeline/stop/start/plan)
  + Score (fleet/caps/suites/runsheet)
AutonomosAskContext (host invite/unit)
  + Organs (global/destination/veto-nightly)
```

### Arquivos
1. ConversationOccasionPack.swift
2. ConversationOccasionPackLive.swift
3. ConversationOccasionPackOrgans.swift
4. ArenaPremiumAskContext.swift
5. ArenaPremiumAskContextLive.swift
6. ArenaPremiumAskContextScore.swift
7. AutonomosAskContext.swift
8. AutonomosAskContextOrgans.swift
9. CODEMAP + design + compress + DONE + LEDGER

### Densidade
| Host | Target |
| OccasionPack host | ≤180 |
| Live/Organs peels | ≤160 each |
| Arena host | ≤230 |
| Autonomos host | ≤200 |

### Fora de escopo
Core · ConversationModel · tipografia · invent pack organs

### §5
nenhum

## DoD produto (≥5)
- [ ] OccasionPack peels host/live/organs
- [ ] ArenaAsk peels host/live/score
- [ ] AutonomosAsk peels host/organs
- [ ] Behavior unchanged (same packFacts wires)
- [ ] Build + checks + guard
- [ ] CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
micro-WAVE · fuse cosmético · multi-domínio collapse · Core

## Plano W3
1. Split peels 2. Gates 3. CODEMAP 4. DONE

## Proof
1. wc hosts under targets
2. gates green
3. DEVICE_PENDING

## Council
After pack sovereignty 157–170, hosts became monólitos — density residual.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · structural density · not micro

### Rejection
rename-only · <5 files → fail

### Related
WAVE-156 density peels · WAVE-157–170 pack wires

### Sequence after
A fill or IDLE ROI

### Acceptance
Build green · peels under target · DEVICE_PENDING

### W2/W3
Split · gates · CODEMAP · DONE · compress · regen · LEDGER

### Honesty
Zero product change — navigation only

### Density table
| Peel | Role |
| OccasionPack | shell |
| PackLive | live organs |
| PackOrgans | residual organs |
| Arena host | invite/canDo |
| Arena Live/Score | control/score |
| Autonomos Organs | destination/veto |

### Product words
None new

### Files
≥8 App + governance

### Notas
append* helpers keep single facts() entry for call sites

### Anti-objetivos again
- inventar
- tipografia
- Core

### Risk
inout append order must preserve pack text stability

### Recovery
git checkout peels

### MARK
// WAVE-171 density peel

### Guard
green required

### End design pad (canon ≥120)
Residual density after pack campaign. Casca only. Zero Core.
ConversationModel deferred. DEVICE_PENDING always.
Gates every App commit. No micro-WAVE invent.
Fila empty residual full-bar or wait A.
Prefer agent-optimal hosts over monólito pack files.

---
*End WAVE-171*
