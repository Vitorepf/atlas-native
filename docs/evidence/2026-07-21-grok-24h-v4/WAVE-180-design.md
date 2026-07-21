# WAVE-180 — execution-state-card-kind-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-180-execution-state-card-kind-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual (A runner-up strip/card after 175–176)
**Δ patamar:** **high**

## Problema
`ExecutionStateCardJudgment` owns exclusive kind chrome (icon · badge ·
spoken · tint · freezesTimer) for `AtlasExecutionPresentationState.Kind` —
**zero packFacts**. Mid-thread pack has strip phase face
(`live_strip_phase`) + proof but **not** StateCard kind
(attention_required / awaiting_external / recovering / replanning / failed /
completed). Agent cannot distinguish “paused for decision” vs “awaiting
external” vs “recovering” from strip phase alone. Dual dialect residual:
UI card publishes kind; pack mute.

## Patamar
| Antes | Depois |
|---|---|
| Strip phase only | Strip phase **+** state_card_kind |
| productWord dead rawValue | productWord used in pack |
| freezesTimer UI-only | pack honesty for timer freeze |
| ≤5s “está pausado por quê?” mute | Pack ≡ StateCard kind law |

Δ = execution presence kind sovereignty mid-thread.

## Arquitetura
Casca only · bubble.executionPresentationState already published.

### Fluxo
```
presenceBubble.executionPresentationState
  → ExecutionStateCardJudgment.packFacts(state:)
  → ConversationOccasionPackLive next to strip organ
```

### Arquivos (≥5)
1. ExecutionStateCardJudgment.swift — packFacts · productWord honesty
2. ConversationOccasionPackLive.swift — wire
3. CODEMAP.md
4. design · compress · DONE · LEDGER
5. (optional) ConversationOccasionPackOrgans if better fit

### Densidade
Judgment +35 · Live +8

### Fora de escopo
Core presentation state · invent kinds · density peels · tipografia ·
strip chrome rewrite · ConversationModel

### §5
nenhum

## DoD produto (≥5)
- [ ] packFacts state_card_kind productWord when state published
- [ ] freezes_timer honesty
- [ ] badge product when present
- [ ] nil state → absence (no invent)
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
micro rename-only · invent kind · Core · tipografia

## Plano W3
1. packFacts 2. wire Live 3. gates 4. CODEMAP DONE compress regen LEDGER

## Proof
1. attentionRequired → kind + freezes yes + badge
2. completed → kind completed
3. no presentation state → absence
4. DEVICE_PENDING

## Council
A runner-up conversation-live-control-strip-card-unify. Full unify of
chrome maps is larger; this wave ships **pack honesty** for kind (the
agent gap) without multi-surface chrome rewrite.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · product pack gap · not idle MARK

### Rejection
delete dead productWord alone · opacity ladder

### Related
WAVE-052 StateCard · WAVE-023 phase/attention · WAVE-160 strip pack

### Sequence after
A may design full strip/card chrome unify later

### Acceptance
Build green · DEVICE_PENDING

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER protect

---

## Appendix — pack shape

```
facts:
- state_card_kind: attention_required
- state_card_freezes_timer: yes
- state_card_badge: PAUSADO
absences:
- execution presentation state não publicado neste recorte
```

## Appendix — non-goals
Do not change StateCard visual. Do not invent Kind.

## Appendix — risk
State optional on bubble — absence honest.

## Appendix — test matrix

| case | expect |
|---|---|
| nil state | absence |
| attentionRequired | freezes yes |
| failed | badge FALHOU |
| completed | kind completed |

## Appendix — commit
`feat(ui): WAVE-180 execution state-card kind pack wire`

## Appendix — god
One law: kind productWord ≡ pack ≡ badge vocabulary

## Appendix — dual A
Full chrome dual map deferred to A design if needed

## Appendix — density
Judgment stays <200

## Appendix — a11y
spoken already Judgment

## Appendix — idle
Not MARK — product pack organ residual full-bar
