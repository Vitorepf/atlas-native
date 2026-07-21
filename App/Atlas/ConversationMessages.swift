import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: ConversationMessages host+scroll+editorial fused

// Messages list surface — empty/load/list host (WAVE-072).
// Parts: ConversationMessagesScroll · ConversationMessagesEditorial · ConversationEmpty*

struct ConversationMessages: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var emptyPrompt: String?
    var emptySuggestions: [String]?
    /// Home partida only — Judgment unlocks default catalog (WAVE-084).
    var isHomePartida: Bool = false
    var hasWorkspaces: Bool = false
    @Environment(AtlasSession.self) var session
    @Binding var awayFromBottom: Bool
    @Binding var lastScrollAt: CFAbsoluteTime
    @Binding var lastScrollBubbleCount: Int
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    var onEditResend: (ChatBubble) -> Void
    var onCopy: (String, String) -> Void

    var body: some View {
        messagesReaderBody
    }
}

// MARK: - Empty / load

extension ConversationMessages {
    @ViewBuilder
    func emptyMessages() -> some View {
        // WAVE-072 surface face; WAVE-084 editorial organ inside empty branch.
        let surface = ConversationMessagesJudgment.face(
            hasLoadError: model.loadError != nil,
            turnCount: model.bubbles.count
        )
        if surface == .loadFail {
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
                suggestions: emptySuggestions,
                isHomePartida: isHomePartida,
                hasWorkspaces: hasWorkspaces
            ) { suggestion in
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                let effort = model.effort
                Task { await model.send(suggestion, effort: effort) }
            }
        }
    }
}

// MARK: - Surface face + list a11y

extension ConversationMessages {
    /// WAVE-072: exclusive messages surface face.
    var messagesFace: ConversationMessagesFace {
        ConversationMessagesJudgment.face(
            hasLoadError: model.loadError != nil,
            turnCount: model.bubbles.count
        )
    }

    func bubblesStackA11y<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                ConversationMessagesJudgment.spokenMessages(turnCount: model.bubbles.count)
            )
            .accessibilityValue(messagesFace.productWord)
    }

    var bubblesBottomAnchor: some View {
        Color.clear.frame(height: 96).id("bottom")
            .background(GeometryReader { geo in
                Color.clear.preference(key: BottomDistanceKey.self,
                                       value: geo.frame(in: .global).minY)
            })
    }

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

// MARK: - Change review chip

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChipButton(for bubble: ChatBubble, trace: TraceID) -> some View {
        Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
            changeReviewChipLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(
            ConversationMessagesJudgment.spokenChangeReview(
                patchCount: model.reviews.changeReviewsByTrace[trace]!.patches.count
            )
        )
        .accessibilityHint(ConversationMessagesJudgment.changeReviewHint)
        .accessibilityIdentifier(A11yID.reviewChip(trace.rawValue))
    }

    func showsChangeReviewChip(for bubble: ChatBubble) -> Bool {
        bubble.role == "assistant"
            && !bubble.streaming
            && bubble.traceId != nil
            && model.reviews.changeReviewsByTrace[bubble.traceId!]?.state == .available
            && ChangeReviewSheet.hasReviewSurface(
                model.reviews.changeReviewsByTrace[bubble.traceId!]!
            )
    }

    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if showsChangeReviewChip(for: bubble), let trace = bubble.traceId {
            changeReviewChipButton(for: bubble, trace: trace)
        }
    }

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

// MARK: - List host

extension ConversationMessages {
    @ViewBuilder
    func messagesList() -> some View {
        if model.bubbles.isEmpty {
            emptyMessages()
        } else {
            bubblesStack
        }
    }

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

// MARK: - Bubble row

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

// MARK: - Scroll (was ConversationMessagesScroll)

// MARK: - Scroll preference

struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// MARK: - Scroll chrome (ConversationMessages peel)

extension ConversationMessages {
    func scrollBubbleEmptyChange(_ empty: Bool) {
        if empty { awayFromBottom = false }
    }

    func scrollBubbleListChange(proxy: ScrollViewProxy) {
        autoScrollToBottom(proxy: proxy)
    }

    @ViewBuilder
    func scrollChrome<Content: View>(proxy: ScrollViewProxy, @ViewBuilder content: () -> Content) -> some View {
        scrollPreferenceChrome(proxy: proxy, content: content)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: showsScrollFAB)
            .onChange(of: model.bubbles.isEmpty) { _, empty in
                scrollBubbleEmptyChange(empty)
            }
            .onChange(of: model.bubbles) {
                scrollBubbleListChange(proxy: proxy)
            }
    }

    var showsScrollFAB: Bool { awayFromBottom && !model.bubbles.isEmpty }

    func autoScrollToBottom(proxy: ScrollViewProxy) {
        guard !model.bubbles.isEmpty else { return }
        let count = model.bubbles.count
        let now = CFAbsoluteTimeGetCurrent()
        guard shouldAutoScroll(now: now, count: count) else { return }
        lastScrollAt = now
        lastScrollBubbleCount = count
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }

    func shouldAutoScroll(now: CFAbsoluteTime, count: Int) -> Bool {
        let countChanged = count != lastScrollBubbleCount
        return countChanged || now - lastScrollAt >= 0.1
    }

    func applyScrollDistancePref<Content: View>(_ content: Content) -> some View {
        content.onPreferenceChange(BottomDistanceKey.self) { minY in
            guard !model.bubbles.isEmpty else {
                awayFromBottom = false
                return
            }
            awayFromBottom = minY > UIScreen.main.bounds.height + 140
        }
    }

    func scrollFABAction(proxy: ScrollViewProxy) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }

    @ViewBuilder
    func scrollFABButton(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollFABAction(proxy: proxy)
        } label: {
            scrollFABLabel
        }
    }

    @ViewBuilder
    func scrollFAB(proxy: ScrollViewProxy) -> some View {
        if showsScrollFAB {
            scrollFABChrome(scrollFABButton(proxy: proxy))
        }
    }

    func scrollFABChrome<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(PressableScale())
            .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
            .transition(reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity))
            .accessibilityLabel(ConversationMessagesJudgment.scrollFABLabel)
            .accessibilityHint(ConversationMessagesJudgment.scrollFABHint)
            .accessibilityIdentifier(A11yID.conversationScrollFAB)
    }

    var scrollFABLabel: some View {
        Image(systemName: "arrow.down")
            .atlasSans(15, .semibold)
            .foregroundStyle(AtlasTheme.textPrimary)
            .frame(width: 40, height: 40)
            .background(Circle().fill(AtlasTheme.surfaceHi)
                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
    }

    @ViewBuilder
    func scrollContentIndicators<Content: View>(_ content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
    }

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

// MARK: - Editorial assembly (was ConversationMessagesEditorial)

// MARK: - Editorial turn assembly (ConversationMessages peel)

extension ConversationMessages {
    func editorialTurn(for bubble: ChatBubble, artifactItems: [AtlasTraceArtifacts.Item]) -> EditorialTurn {
        editorialTurnAssemblyBuilt(bubble: bubble, artifactItems: artifactItems)
    }

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

    var editorialTurnSteerTuple: (
        onSteer: (TraceID) -> Void,
        onOpenArtifacts: (TraceID) -> Void
    ) {
        editorialTurnSteerArtifactsCallbacks()
    }

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

// MARK: - Empty conversation

// MARK: - Host

struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = quote default via Judgment.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    /// Home partida only — unlocks default catalog when suggestions nil.
    var isHomePartida: Bool = false
    var hasWorkspaces: Bool = false
    let onSuggestion: (String) -> Void
    @State private var breathe = false

    init(
        reduceMotion: Bool,
        prompt: String? = nil,
        suggestions: [String]? = nil,
        isHomePartida: Bool = false,
        hasWorkspaces: Bool = false,
        onSuggestion: @escaping (String) -> Void
    ) {
        self.reduceMotion = reduceMotion
        self.prompt = prompt
        self.suggestionsOverride = suggestions
        self.isHomePartida = isHomePartida
        self.hasWorkspaces = hasWorkspaces
        self.onSuggestion = onSuggestion
    }

    private var face: ConversationEmptyFace {
        ConversationEmptyJudgment.face(
            prompt: prompt,
            suggestions: suggestionsOverride,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
    }

    private var displayPrompt: String {
        ConversationEmptyJudgment.resolvedPrompt(prompt)
    }

    private var suggestions: [String] {
        ConversationEmptyJudgment.resolvedSuggestions(
            suggestions: suggestionsOverride,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
                .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
                .accessibilityHidden(true)
            Spacer().frame(height: 40)
            Text("\u{201C}\(displayPrompt)\u{201D}")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityLabel(ConversationEmptyJudgment.spokenPrompt(prompt))
                .accessibilityAddTraits(.isHeader)
                .accessibilityValue(face.productWord)
            Spacer().frame(height: 44)
            if !suggestions.isEmpty {
                VStack(spacing: 10) {
                    ForEach(Array(suggestions.enumerated()), id: \.element) { index, s in
                        Button { onSuggestion(s) } label: {
                            Text(s)
                                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textSecondary)
                                .padding(.horizontal, 18).padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(AtlasTheme.surface)
                                    .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
                        }
                        .buttonStyle(PressableScale())
                        .accessibilityIdentifier(s)
                        .accessibilityLabel(
                            ConversationEmptyJudgment.spokenSuggestion(
                                s, index: index, total: suggestions.count
                            )
                        )
                        .accessibilityHint(ConversationEmptyJudgment.suggestionHint)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, 32).padding(.top, 56)
        .frame(maxWidth: .infinity)
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("conversation.empty.\(face.productWord)")
    }
}
