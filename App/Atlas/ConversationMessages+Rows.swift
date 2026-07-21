import AtlasCore
import SwiftUI

// Cycle 029 fuse → ConversationMessages+Rows.swift

extension ConversationMessages {
    @ViewBuilder
    func bubbleRow(_ bubble: ChatBubble) -> some View {
        let traceArtifacts = bubble.traceId.flatMap { model.reviews.artifactsByTrace[$0] }
        let artifactItems = traceArtifacts?.state == .available ? traceArtifacts?.items ?? [] : []
        editorialTurn(for: bubble, artifactItems: artifactItems)
            .equatable()
            .id(bubble.id)
            .task(id: bubble.traceId?.rawValue) {
                if bubble.role == "assistant", !bubble.streaming, let trace = bubble.traceId {
                    await model.reviews.refreshChangeReview(traceId: trace)
                }
            }
    }
}

extension ConversationMessages {
    func editorialTurnAssemblyBuilt(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item]
    ) -> EditorialTurn {
        editorialTurnAssembly(
            bubble: bubble,
            artifactItems: artifactItems,
            exec: editorialTurnExecTuple(for: bubble),
            steer: editorialTurnSteerTuple
        )
    }
}

extension ConversationMessages {
    func editorialTurnExecTuple(for bubble: ChatBubble) -> (
        onFeedback: (FeedbackKind) -> Void,
        onCopy: () -> Void,
        onEditResend: () -> Void,
        onStop: () -> Void,
        onExecutionChoice: (JobID, String) -> Void,
        onRetry: (JobID) -> Void
    ) {
        editorialTurnExecutionCallbacks(for: bubble)
    }
}

extension ConversationMessages {
    var editorialTurnSteerTuple: (
        onSteer: (TraceID) -> Void,
        onOpenArtifacts: (TraceID) -> Void
    ) {
        editorialTurnSteerArtifactsCallbacks()
    }
}

extension ConversationMessages {
    func editorialTurnAssembly(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item],
        exec: (
            onFeedback: (FeedbackKind) -> Void,
            onCopy: () -> Void,
            onEditResend: () -> Void,
            onStop: () -> Void,
            onExecutionChoice: (JobID, String) -> Void,
            onRetry: (JobID) -> Void
        ),
        steer: (
            onSteer: (TraceID) -> Void,
            onOpenArtifacts: (TraceID) -> Void
        )
    ) -> EditorialTurn {
        EditorialTurn(
            bubble: bubble,
            reduceMotion: reduceMotion,
            onFeedback: exec.onFeedback,
            onCopy: exec.onCopy,
            onEditResend: exec.onEditResend,
            onStop: exec.onStop,
            onExecutionChoice: exec.onExecutionChoice,
            onRetry: exec.onRetry,
            onSteer: steer.onSteer,
            artifactItems: artifactItems,
            onOpenArtifacts: steer.onOpenArtifacts
        )
    }
}

extension ConversationMessages {
    func editorialTurnFeedbackCallbacks(for bubble: ChatBubble) -> (
        onFeedback: (FeedbackKind) -> Void,
        onCopy: () -> Void,
        onEditResend: () -> Void
    ) {
        (
            onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
            onCopy: { onCopy(bubble.text, bubble.role == "user" ? "mensagem" : "resposta") },
            onEditResend: { onEditResend(bubble) }
        )
    }
}

extension ConversationMessages {
    func editorialTurnRunCallbacks() -> (
        onStop: () -> Void,
        onExecutionChoice: (JobID, String) -> Void,
        onRetry: (JobID) -> Void
    ) {
        (
            onStop: { model.cancel() },
            onExecutionChoice: { jobId, optionId in
                Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
            },
            onRetry: { jobId in Task { await model.retryTurn(jobId: jobId) } }
        )
    }
}

extension ConversationMessages {
    func editorialTurnExecutionCallbacks(for bubble: ChatBubble) -> (
        onFeedback: (FeedbackKind) -> Void,
        onCopy: () -> Void,
        onEditResend: () -> Void,
        onStop: () -> Void,
        onExecutionChoice: (JobID, String) -> Void,
        onRetry: (JobID) -> Void
    ) {
        let feedback = editorialTurnFeedbackCallbacks(for: bubble)
        let run = editorialTurnRunCallbacks()
        return (
            onFeedback: feedback.onFeedback,
            onCopy: feedback.onCopy,
            onEditResend: feedback.onEditResend,
            onStop: run.onStop,
            onExecutionChoice: run.onExecutionChoice,
            onRetry: run.onRetry
        )
    }
}

extension ConversationMessages {
    func editorialTurnSteerArtifactsCallbacks() -> (
        onSteer: (TraceID) -> Void,
        onOpenArtifacts: (TraceID) -> Void
    ) {
        (
            onSteer: { trace in steerTrace = ConversationSteerTraceRef(id: trace) },
            onOpenArtifacts: { trace in artifactTrace = ConversationReviewTraceRef(id: trace) }
        )
    }
}

extension ConversationMessages {
    func editorialTurn(for bubble: ChatBubble, artifactItems: [AtlasTraceArtifacts.Item]) -> EditorialTurn {
        editorialTurnAssemblyBuilt(bubble: bubble, artifactItems: artifactItems)
    }
}

extension ConversationMessages {
    func bubblesStackA11y<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationMessagesA11y.spokenMessages(turnCount: model.bubbles.count))
    }
}

extension ConversationMessages {
    var bubblesBottomAnchor: some View {
        Color.clear.frame(height: 96).id("bottom")
            .background(GeometryReader { geo in
                Color.clear.preference(key: BottomDistanceKey.self,
                                       value: geo.frame(in: .global).minY)
            })
    }
}

extension ConversationMessages {
    var bubblesStack: some View {
        bubblesStackA11y(
            LazyVStack(alignment: .leading, spacing: 40) {
                ForEach(model.bubbles) { bubble in
                    if bubble.id == model.firstNewBubbleId {
                        NewSinceLastVisitMarker()
                            .id("new-since-last-visit")
                    }
                    bubbleRow(bubble)
                    changeReviewChip(for: bubble)
                }
                bubblesBottomAnchor
            }
        )
    }
}
