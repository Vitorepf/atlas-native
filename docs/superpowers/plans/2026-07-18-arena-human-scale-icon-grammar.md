# Arena Human Scale and Icon Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Present every Arena score on a human `0...10` scale and make its icon/color grammar quieter and consistent without changing normalized contracts.

**Architecture:** Keep normalized values in AtlasCore and server DTOs. Add a
small pure presentation-scale utility in AtlasCore, route every app string
through `ArenaFormat`, and route Arena symbols through one SwiftUI component
and one semantic symbol map.

**Tech Stack:** Swift 6, SwiftUI, SF Symbols, AtlasCoreChecks, XCUITest.

## Global Constraints

- Scores and deltas are presentation-only `0...10`; stored values stay `0...1`.
- Multipliers remain `×N`, progress remains `%`, coverage remains a count.
- Gold means active; coral means exception; list success never uses green.
- Missing values remain missing.
- No dependency, route, DTO or schema addition.

---

### Task 1: Human score scale

**Files:**
- Create: `Sources/AtlasCore/AtlasArenaPresentationScale.swift`
- Modify: `Sources/AtlasCoreChecks/AtlasArenaChecks.swift`
- Modify: `App/Atlas/ArenaFormat.swift`
- Modify: `App/Atlas/ArenaPremiumResultsView.swift`
- Modify: `App/Atlas/ArenaSuiteSheet+EngineCard.swift`

**Interfaces:**
- Produces: `AtlasArenaPresentationScale.score(_:)` and
  `AtlasArenaPresentationScale.delta(_:)`, both returning a scaled `Double?`.
- Consumes: normalized `Double?` values from current Arena DTOs.

- [ ] Add failing checks proving `0.67 → 6.7`, `1.0 → 10`,
  `-0.06 → -0.6`, and `nil → nil`.
- [ ] Run `env -u ATLAS_LIVE swift run AtlasCoreChecks`; expect the new checks
  to fail because the scale type does not exist.
- [ ] Implement the pure scale utility and make `ArenaFormat.score` and
  `ArenaFormat.signed` use it with zero-or-one fractional digit.
- [ ] Add `/10` only to headline indices and an accessibility value stating
  “de dez”.
- [ ] Run `env -u ATLAS_LIVE swift run AtlasCoreChecks`; expect all checks to
  pass.

### Task 2: Quiet semantic palette

**Files:**
- Modify: `App/Atlas/ArenaPremiumTypes.swift`
- Modify: `App/Atlas/ArenaPremiumOperationalRows.swift`
- Modify: `App/Atlas/ArenaPremiumComparison.swift`
- Modify: `App/Atlas/ArenaPremiumResultsView.swift`
- Modify: `App/Atlas/ArenaPremiumCapabilitiesView.swift`
- Modify: `App/Atlas/ArenaPremiumCapabilityDetail.swift`
- Modify: `App/Atlas/ArenaPremiumStopSheet.swift`

**Interfaces:**
- Consumes: `ArenaPremiumTone`.
- Produces: gold active, coral exception, neutral positive/success grammar.

- [ ] Change `.positive` to a neutral foreground and remove direct green uses
  from Arena files.
- [ ] Keep coral only where the model proves regression, failure or alert.
- [ ] Keep gold only for active controls, live state and selected Atlas arm.
- [ ] Run `rg -n "domAutonomos" App/Atlas/Arena*.swift`; expect no Arena list
  use.

### Task 3: Unified icon component

**Files:**
- Create: `App/Atlas/ArenaPremiumIcon.swift`
- Modify: `App/Atlas/ArenaPremiumPrimitives.swift`
- Modify: `App/Atlas/ArenaPremiumOperationalRows.swift`
- Modify: `App/Atlas/ArenaPremiumResultsView.swift`
- Modify: `App/Atlas/ArenaPremiumCapabilityDetail.swift`
- Modify: `App/Atlas/ArenaPremiumExecutionView.swift`
- Modify: `App/Atlas/ArenaPremiumPlanQueueViews.swift`
- Modify: `App/Atlas/ArenaPremiumAlertsView.swift`

**Interfaces:**
- Produces: `ArenaPremiumIcon`, `ArenaPremiumIconography`, and the common
  chevron rendering.
- Consumes: semantic icon roles and existing suite identifiers.

- [ ] Create a monochrome icon view with a 24 pt optical box and medium weight.
- [ ] Centralize plan, queue, alert, coverage, next, execution and suite symbol
  selection.
- [ ] Replace row-level `Image(systemName:)` instances with the shared view.
- [ ] Keep decorative icons hidden from VoiceOver and preserve row labels.
- [ ] Run `cd App && make build`; expect exit 0.

### Task 4: Visual and physical-device proof

**Files:**
- Modify: `App/UITests/AtlasArenaFlowTests.swift`
- Create: `docs/evidence/2026-07-18-arena-scale-10/`
- Modify: `OBRA.md`

**Interfaces:**
- Consumes: debug Arena fixtures and stable A11y identifiers.
- Produces: simulator captures plus physical-device install/launch proof.

- [ ] Update assertions that expect normalized score strings.
- [ ] Run the focused Arena XCUITests on iPhone 17 Pro Max Simulator.
- [ ] Export and inspect Agora, Resultados, Capacidades and suite-detail
  screenshots.
- [ ] Run `env -u ATLAS_LIVE swift run AtlasCoreChecks`, `cd App && make build`
  and `git diff --check`.
- [ ] Run `cd App && make device`, then verify installation and launch on the
  paired physical iPhone.
- [ ] Append exact results and the physical-device boundary to `OBRA.md`.

