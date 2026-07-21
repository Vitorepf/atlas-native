import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused ConversationMessages · ConversationMessages+Body.swift

// --- ConversationMessages+A11y.swift ---
enum ConversationMessagesA11y {
    static let scrollFABLabel = ConversationMessagesA11yFAB.scrollFABLabel
    static let scrollFABHint = ConversationMessagesA11yFAB.scrollFABHint

    static func spokenMessages(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "conversa, \(turnCount) \(noun)"
    }

    static func spokenChangeReview(patchCount: Int) -> String {
        ConversationMessagesA11yReview.spokenChangeReview(patchCount: patchCount)
    }

    static let changeReviewHint = ConversationMessagesA11yReview.changeReviewHint
}

// --- ConversationMessages+A11yFAB.swift ---
enum ConversationMessagesA11yFAB {
    static let scrollFABLabel = "ir para o fim da conversa"
    static let scrollFABHint = "volta às mensagens mais recentes"
}

// --- ConversationMessages+A11yReview.swift ---
enum ConversationMessagesA11yReview {
    static func spokenChangeReview(patchCount: Int) -> String {
        if patchCount > 0 {
            let noun = patchCount == 1 ? "patch" : "patches"
            return "revisar mudanças, \(patchCount) \(noun)"
        }
        return "revisar mudanças desta execução"
    }

    static let changeReviewHint = "abre arquivos, diff e provas desta execução"
}

// --- ConversationMessages+BubblesA11y.swift ---
extension ConversationMessages {
    func bubblesStackA11y<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationMessagesA11y.spokenMessages(turnCount: model.bubbles.count))
    }
}

// --- ConversationMessages+BubblesBottom.swift ---
extension ConversationMessages {
    var bubblesBottomAnchor: some View {
        Color.clear.frame(height: 96).id("bottom")
            .background(GeometryReader { geo in
                Color.clear.preference(key: BottomDistanceKey.self,
                                       value: geo.frame(in: .global).minY)
            })
    }
}

// --- ConversationMessages+BubblesStack.swift ---
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

// --- ConversationMessages+ChangeReview+Button.swift ---
extension ConversationMessages {
    @ViewBuilder
    func changeReviewChipButton(for bubble: ChatBubble, trace: TraceID) -> some View {
        Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
            changeReviewChipLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(
            ConversationMessagesA11y.spokenChangeReview(
                patchCount: model.reviews.changeReviewsByTrace[trace]!.patches.count
            )
        )
        .accessibilityHint(ConversationMessagesA11y.changeReviewHint)
        .accessibilityIdentifier(A11yID.reviewChip(trace.rawValue))
    }
}

// --- ConversationMessages+ChangeReview+Gate.swift ---
extension ConversationMessages {
    func showsChangeReviewChip(for bubble: ChatBubble) -> Bool {
        bubble.role == "assistant"
            && !bubble.streaming
            && bubble.traceId != nil
            && model.reviews.changeReviewsByTrace[bubble.traceId!]?.state == .available
            && ChangeReviewSheet.hasReviewSurface(
                model.reviews.changeReviewsByTrace[bubble.traceId!]!
            )
    }
}

// --- ConversationMessages+ChangeReview.swift ---
extension ConversationMessages {
    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if showsChangeReviewChip(for: bubble), let trace = bubble.traceId {
            changeReviewChipButton(for: bubble, trace: trace)
        }
    }
}

// --- ConversationMessages+ChangeReviewLabel.swift ---
extension ConversationMessages {
    var changeReviewChipLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.forwardslash.minus").atlasSans(11)
            Text("Revisar mudanças").font(.system(.footnote, weight: .medium))
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 13).padding(.vertical, 7)
        .background(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

// --- ConversationMessages+List.swift ---
extension ConversationMessages {
    @ViewBuilder
    func messagesList() -> some View {
        if model.bubbles.isEmpty {
            emptyMessages()
        } else {
            bubblesStack
        }
    }
}

// --- ConversationMessages+ReaderBody.swift ---
extension ConversationMessages {
    var messagesReaderBody: some View {
        ScrollViewReader { proxy in
            scrollChrome(proxy: proxy) {
                ScrollView {
                    messagesList()
                }
            }
        }
    }
}

// --- ConversationMessages+Rows.swift ---
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

// --- ConversationMessages+RowsTurn+Assembly+Built.swift ---
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

// --- ConversationMessages+RowsTurn+Assembly+ExecTuple.swift ---
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

// --- ConversationMessages+RowsTurn+Assembly+SteerTuple.swift ---
extension ConversationMessages {
    var editorialTurnSteerTuple: (
        onSteer: (TraceID) -> Void,
        onOpenArtifacts: (TraceID) -> Void
    ) {
        editorialTurnSteerArtifactsCallbacks()
    }
}

// --- ConversationMessages+RowsTurn+Assembly.swift ---
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

// --- ConversationMessages+RowsTurn+Execution+Feedback.swift ---
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

// --- ConversationMessages+RowsTurn+Execution+Run.swift ---
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

// --- ConversationMessages+RowsTurn+Execution.swift ---
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

// --- ConversationMessages+RowsTurn+SteerArtifacts.swift ---
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

// --- ConversationMessages+RowsTurn.swift ---
extension ConversationMessages {
    func editorialTurn(for bubble: ChatBubble, artifactItems: [AtlasTraceArtifacts.Item]) -> EditorialTurn {
        editorialTurnAssemblyBuilt(bubble: bubble, artifactItems: artifactItems)
    }
}

// --- ConversationMessages+ScrollFABLabel.swift ---
extension ConversationMessages {
    var scrollFABLabel: some View {
        Image(systemName: "arrow.down")
            .atlasSans(15, .semibold)
            .foregroundStyle(AtlasTheme.textPrimary)
            .frame(width: 40, height: 40)
            .background(Circle().fill(AtlasTheme.surfaceHi)
                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
    }
}

// --- ConversationMessages+ScrollKey.swift ---
struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// --- ConversationMessages+ScrollPreference+Indicators.swift ---
extension ConversationMessages {
    @ViewBuilder
    func scrollContentIndicators<Content: View>(_ content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
    }
}

// --- ConversationMessages+ScrollPreference+Overlay.swift ---
extension ConversationMessages {
    @ViewBuilder
    func scrollFABOverlay<Content: View>(
        proxy: ScrollViewProxy,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .overlay(alignment: .bottomTrailing) {
                scrollFAB(proxy: proxy)
            }
    }
}

// --- ConversationMessages+ScrollPreference.swift ---
extension ConversationMessages {
    @ViewBuilder
    func scrollPreferenceChrome<Content: View>(
        proxy: ScrollViewProxy,
        @ViewBuilder content: () -> Content
    ) -> some View {
        scrollFABOverlay(proxy: proxy) {
            scrollContentIndicators(
                applyScrollDistancePref(content())
            )
        }
    }
}

