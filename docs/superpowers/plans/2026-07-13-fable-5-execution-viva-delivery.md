# Fable 5 Execucao Viva Delivery Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` task-by-task. Tasks use checkbox syntax for tracking.

**Goal:** translate every non-Voice Fable 5 execution state into a real Swift-native Atlas experience backed by Atlas Server data.

**Architecture:** `AtlasCore` owns provider-safe execution state, recovery, plans, queues and Autonomos DTOs. `ConversationModel` and `AutonomosModel` own observable state and actions. Focused SwiftUI views project those models; no view performs network, parsing or persistence. The Fable HTML is the frozen visual source; it never becomes a runtime data source.

**Tech Stack:** Swift 6, SwiftUI, Observation, ActivityKit, APNs, Foundation actors/AsyncSequence, Laravel Atlas Server.

## Global constraints

- Work only on shared local `main`; preserve unrelated WIP and stage explicit files only.
- Voice is excluded: no Voice UI, LiveKit dependency, fake microphone or placeholder.
- Autonomos is a first-class route, never a conversation/cockpit card.
- Values rendered as progress, files, agents, proofs, diffs or state must be supplied by typed runtime contracts; absent contract means absent UI state.
- Every core contract has a golden check. Every visual slice requires `swift run AtlasCoreChecks`, `cd App && make build`, then device proof when device capability is involved.

---

### Task 1: Fidelity matrix and public execution-state contract

**Files:**
- Create: `docs/fable-5-fidelity-matrix.md`
- Create: `Sources/AtlasCore/AtlasExecutionState.swift`
- Create: `Sources/AtlasCoreChecks/AtlasExecutionStateChecks.swift`
- Modify: `Sources/AtlasCoreChecks/main.swift`
- Modify: `App/Atlas/ConversationModel.swift`

- [ ] Map Fable scenes 01–08 and 10–13 plus Fleet to a runtime source, SwiftUI owner, device proof and current gap. Mark Voice excluded.
- [ ] Add a provider-safe `AtlasExecutionState` projection that only decodes an explicit `presentation_state` envelope from trace/stream metadata: `attention_required`, `replanning`, `awaiting_external`, `recovering`, `failed`, `completed`.
- [ ] Include typed public fields only: title, detail, status, checkpoint, retry count, deadline, version and evidence reference. Reject unknown/malformed envelopes rather than fabricating defaults.
- [ ] Add fixture checks for every accepted envelope, malformed input, redaction and state precedence.
- [ ] Project the state in `ChatBubble` with `nil` for unsupported server traces.
- [ ] Run `swift run AtlasCoreChecks` and `cd App && make build`.

### Task 2: Atlas Server execution-state envelopes and actions

**Files:**
- Modify: Atlas Server trace/event writer, interaction routes and resources discovered by Task 1
- Create: focused Laravel feature/unit tests for state envelopes and actions
- Modify: Native `AtlasClient.swift` and `ConversationModel.swift` only if endpoint/action contracts require it

- [ ] Emit the exact public envelope only after a committed ledger event.
- [ ] Add typed action receipts for attention approval/rejection, replan acknowledgement, retry/reconnect and external-wait refresh; require actor and return post-state.
- [ ] Persist checkpoint/version/action receipts; never return raw provider prompt/output.
- [ ] Add native DTO decode and golden checks for each receipt.
- [ ] Verify Laravel tests, Core checks and app build.

### Task 3: Conversation execution surface (Fable Act I + scenes 01–05)

**Files:**
- Create: `App/Atlas/Execution/ExecutionNarrativeView.swift`
- Create: `App/Atlas/Execution/ExecutionStateCards.swift`
- Create: `App/Atlas/Execution/ExecutionPlanView.swift`
- Modify: `App/Atlas/ConversationChrome.swift`
- Modify: `App/Atlas/ConversationCockpit.swift`
- Modify: `App/Atlas/ConversationView.swift`

- [ ] Bind plan N/M exclusively to `executionProgress`; no inferred percentages.
- [ ] Bind narrative rows to safe activities and agent rows to typed jobs.
- [ ] Render attention, replan, recovery and external-wait cards only from Task 1 state, with real model actions from Task 2.
- [ ] Keep composer writable and stop action real throughout every execution state.
- [ ] Match measured Fable typography, order, spacing and motion; support Reduce Motion.
- [ ] Add UI identifiers and XCUITest journeys for active, paused, recovering and completed states.

### Task 4: Completion, artifacts, queue and change review (scenes 10–13)

**Files:**
- Create: `App/Atlas/Execution/ExecutionCompletionView.swift`
- Create: `App/Atlas/Execution/QueuedFollowUpsSheet.swift`
- Create: `App/Atlas/Execution/ChangeReviewView.swift`
- Create: `App/Atlas/Execution/HonestFailureView.swift`
- Modify: `ConversationModel.swift`, Core DTOs/checks and server resources as required by actual artifact/diff/receipt data

- [ ] Bind the Fable queue chip and sheet to `queuedMessages`, `promote(id:)` and `removeQueued(id:)`; automatic FIFO drain remains model-owned.
- [ ] Render completion proof cells, artifact actions and feedback from actual trace results.
- [ ] Add safe diff/review contracts and receipts before rendering accept/reject controls.
- [ ] Render failure/resume only from persisted checkpoint and failure data; verify relaunch and no duplicate send.

### Task 5: Presence, Session Hub and Continuity (Act I + scene 08)

**Files:**
- Create: `App/Atlas/Execution/SessionHubView.swift`
- Create: `App/Atlas/Continuity/ContinuityHandoffView.swift`
- Modify: `App/Atlas/RootView.swift`, `AtlasSession.swift`, `TurnPresence.swift`, `AtlasWidgets.swift`, `AtlasClient.swift`
- Modify: server continuity/session endpoints and tests where missing

- [ ] Add a real Session Hub route with active sessions, own timers, phase, plan state and deep links.
- [ ] Preserve one Live Activity per trace, active session count and the exact Fable lock/Island geometry.
- [ ] Implement canonical handoff receipt and routing between iPhone, Terminal and Desktop; do not copy prompt/history.
- [ ] Verify background lifecycle, app relaunch, two sessions and notification value rules on device.

### Task 6: Autonomos / Frota Viva independent vertical (scenes 06 + Fleet)

**Files:**
- Create: `App/Atlas/Autonomos/AutonomosFleetView.swift`
- Create: `App/Atlas/Autonomos/AutonomosInstanceDetailView.swift`
- Create: `App/Atlas/Autonomos/AutonomosComponents.swift`
- Modify: `RootView.swift`, `AtlasSession.swift`, `AutonomosModel.swift`, Core Autonomos DTOs/checks and server resources as needed

- [ ] Add a dedicated top-level route, entry and deep links for Autonomos.
- [ ] Implement fleet metrics, instance list, mission, host/runtime, workspace, branch, agents, plan, heartbeat, lease, tasks, proof, incident and digest from real records.
- [ ] Implement detail screens for mission, task ledger, artifacts/proofs, incidents, handoff/recovery and provider-safe external brain/muscle contracts.
- [ ] Bind only governed post-state receipts to pause/resume/transfer/open/cancel actions.
- [ ] Verify relaunch and offline/error states without fabricated counts.

### Task 7: Device proof and Fable completion audit

**Files:**
- Modify: `App/UITests/AtlasDeviceProofTests.swift`, `App/scripts/run-device-proof.sh`, `OBRA.md`, `docs/fable-5-fidelity-matrix.md`
- Create: per-scene final device evidence under the established proof location

- [ ] Capture a device screenshot/video for every implemented scene and compare it to the corresponding Fable frame.
- [ ] Execute Core checks, app build, applicable live probes, XCUITests and physical device proof.
- [ ] Record a requirement-by-requirement Fable → model → server → test → evidence audit. A missing real contract is an open requirement, never marked complete.
