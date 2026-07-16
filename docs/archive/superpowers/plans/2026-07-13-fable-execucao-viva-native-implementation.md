# Fable Execução Viva Native Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:executing-plans`
> task-by-task. The visual contract is
> `docs/superpowers/specs/2026-07-13-fable-execucao-viva-native-meta-goal.md`.

**Goal:** deliver the complete Fable 5 Execução Viva experience as a real,
Swift-only Atlas mobile product, from Atlas Terminal/Server events through every
iPhone surface.

**Architecture:** Atlas Terminal/Server remains the canonical execution brain.
`AtlasCore` owns transport, persistence, typed projection and recovery;
`ConversationModel`/`AtlasSession` expose presentation-ready `@Observable`
state; SwiftUI renders the exact Fable visual states; ActivityKit projects the
same session outside the app. Autônomos is a separate 24/7 route, not a card in
the conversation/session hub.

**Tech Stack:** Swift 6, Swift Package Manager, SwiftUI, Observation,
Foundation, URLSession/AsyncSequence, ActivityKit, WidgetKit, UserNotifications,
XCTest/XCUITest, XcodeGen. No new dependency and no TCA.

## Global Constraints

- Work only in `/Users/vitorepf/develop/Atlas/atlas-native` on shared local
  `main`; preserve every concurrent modification.
- The live visual source is `docs/proposals/fable-5.html`. Recalculate its SHA
  before every visual slice; never revert its newer WIP.
- Read `AGENTS.md`, `CLAUDE.md`, `OBRA.md` and the Meta Goal before editing.
- Claim one narrow scope in `OBRA.md`; coordinate any cross-owner seam in §5.
- SwiftUI views render model values/actions only: no endpoint, JSON decoding,
  storage, stream parsing or fake state in View code.
- A real missing value gets an honest typed state; it never becomes invented
  progress, proof, tool, agent, diff, checkpoint or success.
- Use existing Ink & Brass tokens, Fraunces and JetBrains Mono. No visual
  reinterpretation of Fable layout/copy/order/motion.
- Keep view files near 200 lines and split by feature responsibility.
- Every logic change receives a golden check; every interactive visual slice
  receives accessibility identifiers and an XCUITest/device proof.
- Before each scoped commit: `swift run AtlasCoreChecks` and `cd App && make build`.
- Core commits use `feat(core)`/`fix(core)`; visual commits use
  `feat(ui)`/`polish(ui)`; stage exact files only.

---

## File and ownership map

| Area | Owner | Existing files | New focused files when required |
|---|---|---|---|
| Stream, recovery, persistence, contracts | FUNCIONA | `Sources/AtlasCore/InteractionRun.swift`, `AtlasAgentActivity.swift`, `AtlasExecutionProof.swift`, `AtlasAiJobs.swift`, `AtlasAiDecisions.swift`, `AtlasAiQuality.swift` | `AtlasExecutionPlan.swift`, `AtlasQueuedFollowUp.swift`, `AtlasTurnRecovery.swift`, `AtlasAutonomos.swift` |
| Checks | FUNCIONA | `Sources/AtlasCoreChecks/**` | one check file per new contract; never one catch-all suite |
| Presentation models | FUNCIONA | `App/Atlas/ConversationModel.swift`, `AtlasSession.swift` | narrow model extensions or presentation DTO files |
| Conversation composition | CASCA | `ConversationView.swift`, `ConversationChrome.swift`, `ConversationCockpit.swift` | `ExecutionNarrativeView.swift`, `ExecutionComposer.swift`, `QueuedFollowUpsSheet.swift`, `ExecutionCompletionView.swift` |
| Operational states | CASCA | conversation files | `AttentionRequiredView.swift`, `ReplanHistoryView.swift`, `ConnectionRecoveryView.swift`, `ExternalWaitView.swift`, `AgentOrchestraView.swift`, `PeerReviewView.swift`, `ArtifactProofView.swift`, `ChangeReviewView.swift`, `HonestFailureView.swift` |
| Outside-app presence | CASCA + FUNCIONA seam | `TurnPresence.swift`, `AtlasActivityAttributes.swift`, `App/Widgets/AtlasWidgets.swift` | `AtlasLiveActivityDeepLink.swift` only if focused routing cannot live in current files |
| Navigation/autônomos | CASCA + FUNCIONA seam | `RootView.swift`, `WorkspaceView.swift`, `AtlasSession.swift` | `AutonomosFleetView.swift`, `AutonomosInstanceDetailView.swift`, `AutonomosModel.swift` only if the DTO cannot be expressed in AtlasCore |
| Device proof | FUNCIONA | `App/UITests/AtlasDeviceProofTests.swift`, `App/scripts/run-device-proof.sh` | focused `*DeviceProofTests.swift` test files |

## Contract vocabulary

All names are subject to the existing public naming convention, but consumers
must converge on one typed shape rather than parse event metadata in views:

```swift
public struct AtlasExecutionPlan: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let revision: Int
    public let currentStep: Int
    public let totalSteps: Int
    public let state: AtlasExecutionPlanState
    public let changeReason: String?
    public let steps: [AtlasExecutionPlanStep]
}

public struct QueuedMessage: Sendable, Equatable, Identifiable {
    public let id: String
    public let text: String
    public let createdAt: Date
}

public enum AtlasTurnState: Sendable, Equatable {
    case executing
    case awaitingOperator(AtlasAttentionRequest)
    case waitingExternal(AtlasExternalReceipt)
    case reconnecting(AtlasRecoveryState)
    case review(AtlasChangeReview)
    case failed(AtlasTurnFailure)
    case completed(AtlasExecutionCompletion)
}
```

`ConversationModel` is the single UI seam for the active conversation:

```swift
var executionPlan: AtlasExecutionPlan?
var turnState: AtlasTurnState
var queuedMessages: [QueuedMessage]

func queue(text: String)
func promote(id: QueuedMessage.ID)
func removeQueued(id: QueuedMessage.ID)
func resume(from checkpoint: AtlasTurnCheckpoint.ID) async
func resolveAttention(_ option: AtlasAttentionRequest.Option.ID) async
```

`promoteQueued` means “the next turn” only. It never cancels the active run;
turn completion drains the queue FIFO with the same `send` machinery and stable
client identity.

---

### Task 1: Freeze the Fable baseline and make visual comparison reproducible

**Files:**
- Modify: `docs/superpowers/specs/2026-07-13-fable-execucao-viva-native-meta-goal.md` only if its SHA is stale.
- Create: `docs/evidence/2026-07-13/fable-execucao-viva-manifest.md`.
- Create: `docs/evidence/2026-07-13/fable-execucao-viva/` reference screenshots.

- [ ] Record current HTML SHA, current commit/WIP diff and all scene IDs.
- [ ] Capture reference states: executing, completed, lock screen multi-session,
  scenes 1–13, Autônomos fleet and Dynamic Island states.
- [ ] Create a manifest mapping each scene to model state, view file, UI test,
  device screenshot and runtime evidence source.
- [ ] Add an accessibility identifier for every interactive target represented in
  the manifest.
- [ ] Run `git diff --check`, `swift run AtlasCoreChecks` and `cd App && make build`.
- [ ] Commit only evidence/manifest documentation after it represents the latest
  Fable file.

### Task 2: Split the current conversation surface before adding new behavior

**Files:**
- Modify: `App/Atlas/ConversationView.swift`.
- Modify: `App/Atlas/ConversationChrome.swift`.
- Modify: `App/Atlas/ConversationCockpit.swift`.
- Create: `App/Atlas/ExecutionNarrativeView.swift`.
- Create: `App/Atlas/ExecutionComposer.swift`.
- Create: `App/Atlas/ExecutionCompletionView.swift`.
- Test: `App/UITests/AtlasDeviceProofTests.swift`.

- [ ] Move existing layout only, preserving current model calls and visible UI.
- [ ] Define `ExecutionNarrativeView(bubble:reduceMotion:onStop:)` and render
  quote, plan pill, timeline and current action from `ChatBubble` fields.
- [ ] Define `ExecutionComposer(model:draft:focus:)` so draft ownership stays in
  the route and submission stays in `ConversationModel`.
- [ ] Define `ExecutionCompletionView(bubble:onFeedback:onCopy:)` and move
  receipt/proof/final-response presentation into it.
- [ ] Ensure every extracted view has stable `ForEach` identity and does no image
  decode, expensive grouping or metadata parsing in `body`.
- [ ] Add a UI test that opens an existing thread, verifies the composer remains
  present during execution and opens the persisted proof after completion.
- [ ] Build before changing call sites further, then run all gates.

### Task 3: Deliver the plan and public narration contract

**Files:**
- Create: `Sources/AtlasCore/AtlasExecutionPlan.swift`.
- Modify: `Sources/AtlasCore/InteractionRun.swift`.
- Modify: `Sources/AtlasCore/AtlasExecutionProof.swift`.
- Modify: `App/Atlas/ConversationModel.swift`.
- Create: `Sources/AtlasCoreChecks/AtlasExecutionPlanChecks.swift`.

- [ ] Write checks that decode planned steps, update current step, retain plan
  revisions and reject impossible `currentStep > totalSteps` input.
- [ ] Project only provider-safe public intention text and aggregate tool events
  into `AtlasExecutionPlan`/timeline fields.
- [ ] Attach the new values to the active bubble without replacing persisted
  historical activity rows.
- [ ] Expose `executionPlan` in `ConversationModel`; no SwiftUI event parsing.
- [ ] Verify reconnect/replay produces the same ordered plan/timeline with no
  duplicate steps.
- [ ] Run Core checks, App build and a live probe when credentials are present.

### Task 4: Implement Fable conversation execution and conclusion exactly

**Files:**
- Modify: `App/Atlas/ExecutionNarrativeView.swift`.
- Modify: `App/Atlas/ExecutionCompletionView.swift`.
- Modify: `App/Atlas/AtlasMotion.swift`.
- Modify: `App/Atlas/AtlasTheme.swift` and `AtlasType.swift` only for measured
  missing tokens.
- Test: `App/UITests/AtlasDeviceProofTests.swift`.

- [ ] Match Fable's quote, central telemetry pill, connected timeline, serif
  intention, mono tools, current action and settled/current node states.
- [ ] Match completed receipt, three proof cells, final answer, axis list,
  artifact row, signature and feedback pills.
- [ ] Bind files/+/- counts to typed proof/review data; hide only unavailable
  values according to the explicit Fable state, never fabricate them.
- [ ] Apply reduced-motion equivalents without changing hierarchy.
- [ ] Capture executing and completed device screenshots next to reference frames.
- [ ] Run device proof and gates.

### Task 5: Make the composer and FIFO queue fully real

**Files:**
- Create: `Sources/AtlasCore/AtlasQueuedFollowUp.swift`.
- Modify: `App/Atlas/ConversationModel.swift`.
- Create: `Sources/AtlasCoreChecks/AtlasQueuedFollowUpChecks.swift`.
- Modify: `App/Atlas/ExecutionComposer.swift`.
- Create: `App/Atlas/QueuedFollowUpsSheet.swift`.
- Test: `App/UITests/AtlasDeviceProofTests.swift`.

- [ ] Write red checks for enqueue, persistence during navigation, removal,
  promotion-to-next and completion-driven FIFO drain.
- [ ] Store messages under the existing thread/model persistence boundary with
  atomic recovery; retain stable IDs and creation ordering.
- [ ] Route `send` to `queue(text:)` while `isSending`, otherwise keep normal
  send behavior.
- [ ] Render Fable's `Fila N` chip, active composer, sheet title/count, item
  list, send-next and remove controls using real model actions.
- [ ] Make Return/add perform the same enqueue action and ensure stop remains an
  explicit, separate destructive action.
- [ ] XCUITest: send two follow-ups during a run, remove one, promote one,
  complete current run and assert exact FIFO behavior.
- [ ] Run device proof with the actual sheet open.

### Task 6: Project attention, replan, external wait and reconnect

**Files:**
- Create: `Sources/AtlasCore/AtlasTurnState.swift`.
- Modify: `Sources/AtlasCore/InteractionRun.swift`.
- Modify: `Sources/AtlasCore/AtlasAiJobs.swift`.
- Modify: `App/Atlas/ConversationModel.swift`.
- Create: `Sources/AtlasCoreChecks/AtlasTurnStateChecks.swift`.
- Create: `App/Atlas/AttentionRequiredView.swift`.
- Create: `App/Atlas/ReplanHistoryView.swift`.
- Create: `App/Atlas/ConnectionRecoveryView.swift`.
- Create: `App/Atlas/ExternalWaitView.swift`.

- [ ] Define typed state for operator attention, plan revision, receipt wait and
  reconnecting with last sequence/backoff.
- [ ] Add red checks for state transitions, timer pause semantics and replay
  without duplicate sequence/content.
- [ ] Expose only action IDs/labels allowed to the mobile surface; model owns
  submission/resume/cancel operations.
- [ ] Implement the four Fable scenes without generic “trabalhando” fallback.
- [ ] Verify offline, timeout, refused connection and external wait stay
  distinguishable in UI and persisted history.
- [ ] Run Core and device gates for each state fixture.

### Task 7: Implement multi-agent orchestra and peer review

**Files:**
- Modify: `Sources/AtlasCore/AtlasAgentActivity.swift`.
- Modify: `Sources/AtlasCore/AtlasExecutionProof.swift`.
- Modify: `App/Atlas/ConversationModel.swift`.
- Create: `App/Atlas/AgentOrchestraView.swift`.
- Create: `App/Atlas/PeerReviewView.swift`.
- Create: `Sources/AtlasCoreChecks/AtlasAgentOrchestraChecks.swift`.

- [ ] Normalize public agent identity, mission, status, dependency and handoff
  states from server receipts.
- [ ] Preserve agent rows and review decisions in replayed conversation proof.
- [ ] Render Fable orchestra/review states with aggregate activity rather than
  provider-private chain-of-thought.
- [ ] Test an agent waits for a subagent, resumes, reaches review, and preserves
  the reviewer decision after relaunch.
- [ ] Capture the two scene proofs on device.

### Task 8: Implement artifacts, proof and review/diff actions

**Files:**
- Create: `Sources/AtlasCore/AtlasChangeReview.swift`.
- Modify: `Sources/AtlasCore/AtlasExecutionProof.swift`.
- Modify: `App/Atlas/ConversationModel.swift`.
- Create: `Sources/AtlasCoreChecks/AtlasChangeReviewChecks.swift`.
- Create: `App/Atlas/ArtifactProofView.swift`.
- Create: `App/Atlas/ChangeReviewView.swift`.
- Test: `App/UITests/AtlasDeviceProofTests.swift`.

- [ ] Define typed artifacts, checks, warning counts, summary and bounded diff
  snippets with links to a ledger/proof identifier.
- [ ] Define approve-all, file-level decision and reject action results; never
  mark review complete before the server receipt confirms it.
- [ ] Render the Fable artifact and scene-12 review surfaces exactly, including
  +/− totals, filenames, died/born lines and action pills.
- [ ] Test artifact actions and review choices persist, replay and correctly
  represent server refusal/failure.
- [ ] Run live probe and device screenshot comparison.

### Task 9: Implement honest failure, checkpoint and resume

**Files:**
- Create: `Sources/AtlasCore/AtlasTurnRecovery.swift`.
- Modify: `Sources/AtlasCore/InteractionRun.swift`.
- Modify: `App/Atlas/ConversationModel.swift`.
- Create: `Sources/AtlasCoreChecks/AtlasTurnRecoveryChecks.swift`.
- Create: `App/Atlas/HonestFailureView.swift`.
- Test: `App/UITests/AtlasDeviceProofTests.swift`.

- [ ] Define error kind, failing step, timeout/reason, checkpoint identity and
  legal recovery options.
- [ ] Test exact cancel/retry/reconnect behavior, immutable prior history and
  continuation in a new sequence without duplicate response/text.
- [ ] Render Fable's named failure callout, actions and resumed-row transition.
- [ ] Ensure timer and queue survive failure according to state policy.
- [ ] Device test failure → resume → proof replay.

### Task 10: Unify notification, lock screen and Dynamic Island per session

**Files:**
- Modify: `App/Atlas/AtlasActivityAttributes.swift`.
- Modify: `App/Atlas/TurnPresence.swift`.
- Modify: `App/Widgets/AtlasWidgets.swift`.
- Modify: `App/Atlas/AtlasApp.swift` and `RootView.swift` for deep-link routing.
- Modify: `App/project.yml`, entitlements/Info.plist only when required by the
  actual capability.
- Create: `App/UITests/AtlasLiveActivityRoutingTests.swift` where feasible.

- [ ] Maintain one Live Activity per executing session, each with independent
  title, phase, timer, completion and shared active-session count.
- [ ] Show state-specific Fable content: executing, plan/replan, attention,
  response ready and session ended.
- [ ] Add provider-safe local notification at real completion, requested only at
  the moment of value; wire APNs as a separately proven server-backed phase.
- [ ] Route activity/notification tap to the exact canonical thread.
- [ ] Validate two concurrent sessions and one completion update; snapshot lock,
  expanded/compact/minimal Dynamic Island states on physical iPhone.

### Task 11: Implement continuity between iPhone, Desktop and Terminal

**Files:**
- Create or modify focused Core continuity DTO/client files after placement.
- Modify: `App/Atlas/AtlasSession.swift`.
- Create: `App/Atlas/ContinuityHandoffView.swift`.
- Create: corresponding Core check file.

- [ ] Place the feature with Atlas and use the existing session identity rather
  than a new conversation copy.
- [ ] Expose available device/runtime, ownership, session cursor and handoff
  action as typed contract.
- [ ] Implement Fable scene 08: iPhone follows, Mac assumes, Terminal opens
  correct workspace/branch/thread with no prompt copy.
- [ ] Verify handoff/relaunch maintains one event ledger and one queue.

### Task 12: Implement voice as a real vertical, not mock controls

**Files:**
- Inspect existing voice/LiveKit package and native permissions first.
- Modify focused voice adapter/model files only after the contract is verified.
- Create: `App/Atlas/VoiceExecutionView.swift`.
- Modify: `App/Atlas/AtlasActivityAttributes.swift` and widgets for the shared
  state projection.
- Create: focused Core/model/device tests.

- [ ] Define listening, responding and executing state transitions plus partial
  caption and interrupt action.
- [ ] Request microphone permission at a value moment with an explanatory state.
- [ ] Mirror the same state in conversation and Dynamic Island.
- [ ] If the real server/LiveKit contract is unavailable, mark this vertical as
  externally blocked in `OBRA.md`; do not ship simulated mic behavior.

### Task 13: Add the Autônomos 24/7 Core contract

**Files:**
- Create: `Sources/AtlasCore/AtlasAutonomos.swift`.
- Modify: `Sources/AtlasCore/AtlasClient.swift` and focused endpoints only after
  placement/server contract confirmation.
- Create: `Sources/AtlasCoreChecks/AtlasAutonomosChecks.swift`.
- Modify: `App/Atlas/AtlasSession.swift`.

- [ ] Model fleet totals, instance identity, placement, host/runtime, workspace,
  branch, capabilities, mission, limits, plan, agents, tool aggregates, uptime,
  heartbeat, lease, checkpoint, task ledger, incidents, digest and controls.
- [ ] Make external-brain/muscle prompts provider-safe by default; raw details
  require explicit audit mode.
- [ ] Test all status counts, stale/lease detection, action authorization and
  recovery/handoff persistence.
- [ ] Live-probe server data; absent server fields remain absent in UI.

### Task 14: Build Autônomos as an independent command center

**Files:**
- Modify: `App/Atlas/RootView.swift`.
- Create: `App/Atlas/AutonomosFleetView.swift`.
- Create: `App/Atlas/AutonomosInstanceDetailView.swift`.
- Create: `App/Atlas/AutonomosTaskLedgerView.swift`.
- Create: `App/UITests/AtlasAutonomosDeviceProofTests.swift`.

- [ ] Add a top-level route distinct from conversation/session cockpit.
- [ ] Reproduce Fable's fleet dashboard: title/counts/grid, live instance rows,
  uptime, heartbeat, progress, exception-only lease alert, transfer actions and
  digest.
- [ ] Build drill-down views for mission, task ledger, evidence, decisions,
  incidents, handoffs and governed controls.
- [ ] Ensure healthy work becomes digest/checkpoint; follow notifications appear
  only for attention or explicit operator follow.
- [ ] Device proof fleet → instance → incident transfer → resolved digest.

### Task 15: Performance, accessibility and hardware behavior audit

**Files:**
- Modify only files whose code-first audit identifies a concrete issue.
- Create: `docs/evidence/2026-07-13/fable-execucao-viva-performance.md`.

- [ ] Audit Observation scope, list identity, derived work in `body`, image
  decoding, transitions, layout depth, timers and stream event throttling.
- [ ] Move heavy processing to Core/model preprocessing; retain snapshots/value
  types in the view layer; do not use `AnyView` as a workaround.
- [ ] Capture Instruments on physical iPhone: launch, streaming timeline,
  scrolling long proof, queue sheet, multi-session activity and Autônomos fleet.
- [ ] Record exact baseline/final evidence, remaining platform limits and no
  unverified performance claim.
- [ ] Validate Dynamic Type, focus order, labels/traits, contrast and Reduce
  Motion without introducing visual components absent from Fable.

### Task 16: Full product acceptance and evidence closeout

**Files:**
- Modify: `OBRA.md` delivery/evidence sections.
- Create: `docs/evidence/2026-07-13/fable-execucao-viva/final-acceptance.md`.

- [ ] Run all Core checks, App build, applicable live probes, all XCUITests and
  physical-device proof from a clean generated project.
- [ ] Compare device and Fable screenshots for Ato I, scenes 1–13, fleet,
  notification, lock screen and every Dynamic Island variant.
- [ ] Re-run network loss, server wait, two sessions, queue drain, failure/resume,
  relaunch, handoff and background scenarios.
- [ ] Audit staged files, warnings, dependencies, `git diff --check` and every
  OBRA claim/evidence field.
- [ ] Commit only verified slices, write the final acceptance with actual command
  outputs and list external blockers that remain outside the repo.

## Coverage matrix

| Fable surface | Tasks |
|---|---|
| Conversation live + completed | 2–4 |
| Queue/composer | 5 |
| Attention, replan, reconnect, external wait | 6 |
| Agent orchestra + peer review | 7 |
| Artifact/proof + diff review | 8 |
| Honest failure/checkpoint/resume | 9 |
| Notification, lock screen, Live Activity, Dynamic Island | 10 |
| Cross-device continuity | 11 |
| Voice | 12 |
| Autônomos 24/7 | 13–14 |
| Lightweight/polished/hardware-near audit | 15 |
| Full proof | 16 |

## Completion definition

The plan is complete only when every checkbox is checked with evidence,
all Fable scenes exist as real product states, the iPhone experience is visually
faithful, all actions use real contracts, and the gates/device proofs pass. A
mock, a static state, a build-only result, an unconnected scene or a claimed
future vertical does not satisfy this definition.
