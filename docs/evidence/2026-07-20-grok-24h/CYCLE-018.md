# CYCLE-018 — PlanCard host/steps/a11y ~32→3

## Hipótese
Floresta PlanCard (69 peels) da conversa. Fundir host+steps+a11y primeiro.

## Fuse
- PlanCard.swift — gate, chrome, body, header, progress, steps factory/state
- PlanCard+StepRow.swift — layout, dot, spine, pulse, a11y chrome
- PlanCard+A11y.swift — spoken card/step/chip/progress/detail/revision

## Residual
Audit*, DetailChips*, FlexWrap*, Revisions* (~38 peels)

## Gates
checks+build green · `f45e87dc` · App/Atlas 1692→1664
