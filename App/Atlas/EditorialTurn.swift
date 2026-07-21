import AtlasCore
import SwiftUI

// IDLE-COMPRESS MARK + canonical layout (WAVE-post · agent navigation)

// MARK: - Types / Inputs

struct EditorialTurn: View, Equatable {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    var onEditResend: () -> Void = {}
    let onStop: () -> Void
    let onExecutionChoice: (JobID, String) -> Void
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (TraceID) -> Void = { _ in }
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State var placed = false

    // MARK: Body

    var body: some View {
        applyArrival(turnBody)
    }
}

// MARK: - Body / Sections (assistant)

extension EditorialTurn {
    func applyArrival<Content: View>(_ content: Content) -> some View {
        content
            .opacity(placed ? 1 : 0)
            .offset(y: placed ? 0 : 12)
            .onAppear {
                if reduceMotion { placed = true }
                else { withAnimation(AtlasMotion.arrival) { placed = true } }
            }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantTurn: some View {
        VStack(alignment: .leading, spacing: 12) {
            assistantPlanCard
            assistantExecutionRibbon
            assistantExecutionBlock
            assistantClosing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
        .accessibilityHint(EditorialTurnJudgment.copyLongPressHint)
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionBlock: some View {
        if let state = bubble.executionPresentationState {
            assistantExecutionCard(state)
        }
    }
}

extension EditorialTurn {
    @ViewBuilder
    func assistantExecutionCard(_ state: AtlasExecutionPresentationState) -> some View {
        if ExecutionStateCard.shouldDisplay(state: state) {
            ExecutionStateCard(
                state: state,
                jobId: bubble.executionChoiceJobId,
                onChoose: onExecutionChoice,
                retryableJobId: bubble.retryableJobId,
                onRetry: onRetry,
                onSteer: assistantSteerHandler
            )
        }
    }
}

extension EditorialTurn {
    var assistantSteerHandler: (() -> Void)? {
        let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
        return steerTrace.map { trace in { onSteer(trace) } }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantPlanCard: some View {
        PlanCard(bubble: bubble)
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionRibbon: some View {
        // WAVE-027: presence-ongoing keeps ribbon; not streaming-only (sink ≡ strip).
        // WAVE-012 dual-surface reconnect silence remains inside ExecutionRibbon.
        if bubble.hasLiveExecutionSurface,
           ConversationExecutionPhase.isPresenceOngoing(bubble) {
            ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
        }
    }
}

// MARK: - Body branches

extension EditorialTurn {
    @ViewBuilder
    var turnBodyAssistantBranch: some View {
        assistantTurn
    }
}

extension EditorialTurn {
    @ViewBuilder
    var turnBodyUserBranch: some View {
        userTurn
    }
}

extension EditorialTurn {
    var turnBody: some View {
        Group {
            if bubble.role == "user" {
                turnBodyUserBranch
            } else {
                turnBodyAssistantBranch
            }
        }
    }
}

// MARK: - Equatable

extension EditorialTurn {
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }
}
