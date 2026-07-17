import SwiftUI
import AtlasCore

// Empty + bubbles LazyVStack — peel de ConversationMessages (régua ≤100).

extension ConversationMessages {
    @ViewBuilder
    func messagesList() -> some View {
        if model.bubbles.isEmpty {
            emptyMessages()
        } else {
            LazyVStack(alignment: .leading, spacing: 40) {
                ForEach(model.bubbles) { bubble in
                    if bubble.id == model.firstNewBubbleId {
                        NewSinceLastVisitMarker()
                            .id("new-since-last-visit")
                    }
                    bubbleRow(bubble)
                    changeReviewChip(for: bubble)
                }
                Color.clear.frame(height: 96).id("bottom")
                    .background(GeometryReader { geo in
                        Color.clear.preference(key: BottomDistanceKey.self,
                                               value: geo.frame(in: .global).minY)
                    })
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationMessagesA11y.spokenMessages(turnCount: model.bubbles.count))
        }
    }

    @ViewBuilder
    private func emptyMessages() -> some View {
        if model.loadError != nil {
            AtlasNetworkFailureEmpty(
                kind: model.loadFailureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 100,
                retryHint: "reconecta e recarrega esta conversa",
                accessibilityIdentifier: A11yID.conversationLoadFailure,
                onRetry: { Task { await model.load() } }
            )
        } else {
            EmptyConversation(
                reduceMotion: reduceMotion,
                prompt: emptyPrompt,
                suggestions: emptySuggestions
            ) { suggestion in
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                let effort = model.effort
                Task { await model.send(suggestion, effort: effort) }
            }
        }
    }

    @ViewBuilder
    private func bubbleRow(_ bubble: ChatBubble) -> some View {
        let traceArtifacts = bubble.traceId.flatMap { model.reviews.artifactsByTrace[$0] }
        let artifactItems = traceArtifacts?.state == .available ? traceArtifacts?.items ?? [] : []
        EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                      onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                      onCopy: { onCopy(bubble.text, bubble.role == "user" ? "mensagem" : "resposta") },
                      onEditResend: { onEditResend(bubble) },
                      onStop: { model.cancel() },
                      onExecutionChoice: { jobId, optionId in
                          Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
                      },
                      onRetry: { jobId in
                          Task { await model.retryTurn(jobId: jobId) }
                      },
                      onSteer: { trace in steerTrace = ConversationSteerTraceRef(id: trace) },
                      artifactItems: artifactItems,
                      onOpenArtifacts: { trace in artifactTrace = ConversationReviewTraceRef(id: trace) })
        .equatable()
        .id(bubble.id)
        .task(id: bubble.traceId?.rawValue) {
            if bubble.role == "assistant", !bubble.streaming, let trace = bubble.traceId {
                await model.reviews.refreshChangeReview(traceId: trace)
            }
        }
    }
}
