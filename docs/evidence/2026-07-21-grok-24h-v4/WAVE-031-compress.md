# WAVE-031 W3 compress — conversation-decision-control-instrument

**Date:** 2026-07-21  
**Wave:** WAVE-031  
**Implementer:** Grok B v5

## W2 DoD

| DoD | Proof |
|---|---|
| Strip Escolher when actions | ExecutingStrip + ConversationDecisionJudgment |
| Same resolve path | onChoose → model.resolveExecutionChoice |
| Face honesty attentionRequired | face(for:state) → paused; primarySpoken decision lead |
| Silence without actions | isDecisionRequired requires actions+jobId |
| StateCard aligned | primarySpoken(for: state) |
| A11y decision words | stripAccessibilityLabel + card spoken |
| LiveNow | no choice payload on snapshot — silence (no fake) |
| CODEMAP | conversation decision control |

## DEVICE

DEVICE_PENDING
