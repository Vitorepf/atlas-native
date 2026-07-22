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
                retryHint: ConversationMessagesJudgment.spokenReloadConversationHint,
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
        .accessibilityHint(ConversationMessagesJudgment.spokenChangeReviewHint)
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
            Text(ChangeReviewSheetJudgment.productTitle).font(.system(.footnote, weight: .medium))
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
            .accessibilityLabel(ConversationMessagesJudgment.spokenScrollFAB)
            .accessibilityHint(ConversationMessagesJudgment.spokenScrollFABHint)
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
                        .accessibilityHint(ConversationEmptyJudgment.spokenSuggestionHint)
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

// MARK: - SteerInteractionSheet

// MARK: - Host

struct SteerInteractionSheet: View {
    let traceId: TraceID
    var model: ConversationModel
    let onSubmit: (String, AtlasInteractionSteerScope) -> Void

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var instruction = ""
    @State var scope: AtlasInteractionSteerScope = .currentStep

    var body: some View {
        steerA11yShell(steerNavigationStack)
    }
}

// MARK: - Body

// MARK: - Scope · receipt · fields

extension SteerInteractionSheet {
    /// WAVE-053: face + submit from Judgment.
    var steerFace: ConversationSteerFace {
        ConversationSteerJudgment.face(
            instruction: instruction,
            last: model.lastSteerReceipt,
            traceId: traceId
        )
    }

    var canSubmit: Bool {
        ConversationSteerJudgment.allowsSubmit(instruction: instruction)
    }

    func spokenReceiptLabel(_ receipt: AtlasInteractionSteerResponse) -> String {
        ConversationSteerJudgment.spokenReceipt(receipt)
    }

    func spokenScopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        ConversationSteerJudgment.spokenScope(scope)
    }

    func spokenSheetHint() -> String {
        "instrução entra no próximo checkpoint seguro; o Atlas pode recusar"
    }

    func spokenSubmitLabel(canSubmit: Bool) -> String {
        ConversationSteerJudgment.spokenSubmitLabel(allowsSubmit: canSubmit)
    }

    func spokenSubmitHint(canSubmit: Bool) -> String {
        ConversationSteerJudgment.spokenSubmitHint(allowsSubmit: canSubmit)
    }
}

extension SteerInteractionSheet {
    func steerA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.steerSheet)
            .accessibilityLabel(ConversationSteerJudgment.spokenSheetTitle(traceId: traceId))
            .accessibilityHint(spokenSheetHint())
    }
}

extension SteerInteractionSheet {
    var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            formHeader
            instructionField
            formReceiptLine
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: matchedReceipt)
    }
}

extension SteerInteractionSheet {
    var formHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(ConversationLiveStripJudgment.productSteer)
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(ConversationMessagesJudgment.productSteerHonesty)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            formScopePicker
        }
    }
}

extension SteerInteractionSheet {
    var formScopePicker: some View {
        // WAVE-053: product PT labels (not wire raw current_step/replan).
        Picker("Escopo", selection: $scope) {
            ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                Text(ConversationSteerJudgment.productScope(scope)).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier(A11yID.steerScope)
        .accessibilityLabel(spokenScopeLabel(scope))
    }
}

extension SteerInteractionSheet {
    @ViewBuilder
    var formReceiptLine: some View {
        if let receipt = matchedReceipt {
            receiptLine(receipt)
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityIdentifier(A11yID.steerReceipt)
                .accessibilityLabel(spokenReceiptLabel(receipt))
        }
    }
}

extension SteerInteractionSheet {
    var instructionField: some View {
        TextField("O que muda a partir daqui?", text: $instruction, axis: .vertical)
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent)
            .lineLimit(3...7)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityIdentifier(A11yID.steerInstruction)
            .accessibilityHint(ConversationMessagesJudgment.spokenSteerFieldHint)
    }
}

extension SteerInteractionSheet {
    var steerNavigationStack: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                formContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { steerToolbar }
        }
    }
}

extension SteerInteractionSheet {
    var matchedReceipt: AtlasInteractionSteerResponse? {
        ConversationSteerJudgment.matchedReceipt(
            last: model.lastSteerReceipt,
            traceId: traceId
        )
    }
}

extension SteerInteractionSheet {
    func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> some View {
        // WAVE-053: copy + tint from Judgment face.
        Text(ConversationSteerJudgment.receiptLine(receipt))
            .font(AtlasFont.mono(11))
            .foregroundStyle(receipt.isAccepted ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface.opacity(0.65)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .accessibilityValue(receipt.isAccepted ? "accepted" : "rejected")
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerToolbar: some ToolbarContent {
        steerCancelItem
        steerSubmitItem
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerCancelItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar redirecionamento",
                spokenHint: "fecha sem enviar instrução",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerSubmitItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            steerSubmitButton
        }
    }
}

extension SteerInteractionSheet {
    var steerSubmitButton: some View {
        Button(ConversationMessagesJudgment.productSteerSubmit) {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSubmit(instruction, scope)
        }
        .disabled(!canSubmit)
        .accessibilityIdentifier(A11yID.steerSubmit)
        .accessibilityLabel(spokenSubmitLabel(canSubmit: canSubmit))
        .accessibilityHint(spokenSubmitHint(canSubmit: canSubmit))
        .accessibilityValue(steerFace.productWord)
    }
}

// MARK: - QueuedFollowUpRow

// MARK: - Row

// MARK: - Host

struct QueuedFollowUpRow: View {
    let message: QueuedMessage
    let index: Int
    let total: Int
    let onPromote: () -> Void
    let onRemove: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        rowLayout
    }
}

// MARK: - Body

extension QueuedFollowUpRow {
    var promoteLabel: String { "enviar agora, \(positionCaption): \(message.text)" }
    var promoteHint: String { "torna esta mensagem a próxima instrução; o turno atual continua" }
    var removeLabel: String { "remover da fila, \(positionCaption): \(message.text)" }
    var removeHint: String { "remove da fila sem enviar" }
}

extension QueuedFollowUpRow {
    var positionCaption: String {
        let ordinal = index + 1
        if ordinal == 1 { return "próxima na fila" }
        return "\(ordinal)ª na fila"
    }

    var rowSpokenLabel: String {
        let ordinal = index + 1
        if total == 1 { return message.text }
        if ordinal == 1 { return "primeira na fila, \(total) no total. \(message.text)" }
        return "\(ordinal)ª de \(total) na fila. \(message.text)"
    }
}

extension QueuedFollowUpRow {
    var promoteButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onPromote()
        } label: {
            Image(systemName: "arrow.up")
                .atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AtlasTheme.goldVeil))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(promoteLabel)
        .accessibilityHint(promoteHint)
        .accessibilityIdentifier(A11yID.queuePromote(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            rowText
            promoteButton
            removeButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .accessibilityIdentifier(A11yID.queueRow(index))
        .overlay(alignment: .bottom) {
            Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
                .accessibilityHidden(true)
        }
    }
}

extension QueuedFollowUpRow {
    var removeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRemove()
        } label: {
            Image(systemName: "trash")
                .atlasSans(14)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AtlasTheme.surfaceHi))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(removeLabel)
        .accessibilityHint(removeHint)
        .accessibilityIdentifier(A11yID.queueRemove(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowMessagePreview: some View {
        Text(message.text)
            .font(AtlasFont.serif(16))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}

extension QueuedFollowUpRow {
    @ViewBuilder
    var rowPositionCaption: some View {
        if total > 1 {
            Text(positionCaption)
                .font(AtlasFont.mono(10))
                .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension QueuedFollowUpRow {
    var rowText: some View {
        VStack(alignment: .leading, spacing: 4) {
            rowPositionCaption
            rowMessagePreview
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowSpokenLabel)
    }
}

// MARK: - Sheet

// MARK: - Host

struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss

    var model: ConversationModel

    var body: some View {
        queueSheetA11yShell(queueSheetBodyBranch)
    }
}

// MARK: - Body

extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            .accessibilityLabel(spokenQueueSheetLabel())
            .accessibilityHint(ConversationMessagesJudgment.spokenQueueManageHint)
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueOrderCaption(total: Int) -> some View {
        if total > 1 {
            Text("ordem da fila · a cabeça envia quando o turno terminar")
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(
                    "fila ordenada; a primeira mensagem envia quando o turno atual terminar"
                )
        }
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueMessageRows(messages: [QueuedMessage]) -> some View {
        let total = messages.count
        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
            QueuedFollowUpRow(
                message: message,
                index: index,
                total: total,
                onPromote: { Task { await model.promote(id: message.id) } },
                onRemove: { Task { await model.removeQueued(id: message.id) } }
            )
            .transition(reduceMotion ? .identity : .opacity)
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: messages.map(\.id))
    }
}

extension QueuedFollowUpsSheet {
    var sheetContent: some View {
        let messages = model.queuedMessages
        let total = messages.count
        return SheetShell(title: sheetTitle(count: total)) {
            queueOrderCaption(total: total)
            queueMessageRows(messages: messages)
        }
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    var queueSheetBodyBranch: some View {
        if model.queuedMessages.isEmpty {
            emptyQueueDismiss
        } else {
            sheetContent
        }
    }
}

extension QueuedFollowUpsSheet {
    var emptyQueueDismiss: some View {
        Color.clear.onAppear { dismiss() }
    }
}

extension QueuedFollowUpsSheet {
    /// WAVE-051: titles/spoken via queue head judgment.
    func sheetTitle(count: Int) -> String {
        _ = count
        return ComposerQueueJudgment.productSheetTitle(from: model.queuedMessages)
    }

    func spokenQueueSheetLabel() -> String {
        ComposerQueueJudgment.spokenSheet(from: model.queuedMessages)
    }
}
