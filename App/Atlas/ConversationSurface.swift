import SwiftUI
import AtlasCore
import PhotosUI

// GOD-RESTRUCTURE: ConversationSurface* peels fused (ConversationView extensions)

// MARK: - Surface core (seed/lifecycle/presence)

// MARK: - Seed / model

extension ConversationView {
    static func initModelState(
        client: AtlasClient,
        threadId: ThreadID?,
        taskKind: String?,
        workspace: String?,
        draft: String,
        turnFacts: ((String) async -> String?)? = nil
    ) -> State<ConversationModel> {
        State(initialValue: Self.seededModel(
            client: client,
            threadId: threadId,
            taskKind: taskKind,
            workspace: workspace,
            draft: draft,
            turnFacts: turnFacts
        ))
    }
}

extension ConversationView {
    static func seededModel(
        client: AtlasClient,
        threadId: ThreadID?,
        taskKind: String?,
        workspace: String?,
        draft: String,
        turnFacts: ((String) async -> String?)?
    ) -> ConversationModel {
        let model = ConversationModel(client: client, threadId: threadId)
        model.turnFacts = turnFacts
        model.taskKind = taskKind
        Self.seedWorkspace(on: model, workspace: workspace)
        Self.seedDraft(on: model, draft: draft)
        return model
    }
}

extension ConversationView {
    static func seedDraft(on model: ConversationModel, draft: String) {
        guard !draft.isEmpty else { return }
        model.updateDraft(draft)
    }
}

extension ConversationView {
    static func seedWorkspace(on model: ConversationModel, workspace: String?) {
        guard let workspace else { return }
        model.workspaceSlug = workspace
        model.workspaceName = workspace
    }
}

// MARK: - Lifecycle

extension ConversationView {
    func applySendHaptic<Content: View>(_ content: Content) -> some View {
        content
            .onChange(of: model.isSending) { was, now in
                if was && !now { AtlasMotion.successNotification(reduceMotion: reduceMotion) }
            }
    }
}

extension ConversationView {
    func conversationLifecycleModifiers<Content: View>(_ content: Content) -> some View {
        conversationOutlineSheet(
            presenceModifiers(
                applySendHaptic(
                    applyCacheLifecycleModifiers(content)
                        .task { await model.load() }
                )
            )
        )
    }
}

extension ConversationView {
    func applyCacheLifecycleModifiers<Content: View>(_ content: Content) -> some View {
        content
            .onChange(of: model.cacheCapturedAt) { _, capturedAt in
                if let capturedAt { lastCacheCapturedAt = capturedAt }
            }
            .onChange(of: model.showingStaleCache) { was, now in
                if now, let capturedAt = model.cacheCapturedAt {
                    lastCacheCapturedAt = capturedAt
                } else if was && !now, lastCacheCapturedAt != nil {
                    readSealConfirming = true
                }
            }
    }
}

extension ConversationView {
    func conversationOutlineSheet<Content: View>(_ content: Content) -> some View {
        content.sheet(isPresented: $showOutline) {
            ConversationOutlineSheet(bubbles: model.bubbles, reduceMotion: reduceMotion)
        }
    }
}

// MARK: - Presence

extension ConversationView {
    func presenceOnAppear() {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: model.threadId)
        TurnPresence.shared.setVisible(model, visible: true)
        rebindMidThreadTurnFacts()
        if startFocused && model.bubbles.isEmpty {
            // Espera a sheet assentar; 0.45 sentia lento demais.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { focused = true }
        }
    }
}

extension ConversationView {
    func presenceOnDisappear() {
        TurnPresence.shared.setVisible(model, visible: false)
        model.markThreadVisited()
    }
}

extension ConversationView {
    func presenceOnThreadChange(_ now: ThreadID?) {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
        TurnPresence.shared.setVisible(model, visible: true)
        rebindMidThreadTurnFacts()
        if let now { onThread?(now) }
    }
}

// MARK: - WAVE-106 mid-thread pack hydration

extension ConversationView {
    /// Rebind turnFacts to close over ConversationModel (queue/plan/lanes/decision).
    /// Home/Workspace partida keep their own pack (do not override).
    func rebindMidThreadTurnFacts() {
        guard !isHomePartida else { return }
        // Only mid-thread occasion (ConversationOccasionPack invite path / open thread).
        guard emptyPrompt == ConversationOccasionPack.invite
                || model.threadId != nil else { return }
        let threadTitle = title
        model.turnFacts = { [session, model, threadTitle] _ in
            guard let threadId = model.threadId else {
                return nil
            }
            let bubble = ConversationExecutionPhase.selectPresenceBubble(from: model.bubbles)
            let presenceTrace = bubble?.traceId
            let review = presenceTrace.flatMap { model.reviews.changeReviewsByTrace[$0] }
            // Load finished when review published or not currently in-flight.
            let reviewFinished = presenceTrace.map { tid in
                review != nil || !model.reviews.changeReviewInFlight.contains(tid)
            } ?? false
            let artifactsBag: AtlasTraceArtifacts? = {
                guard let tid = presenceTrace else { return nil }
                return model.reviews.artifactsByTrace[tid]
            }()
            let artifacts: [AtlasTraceArtifacts.Item] = artifactsBag?.items ?? []
            let published = ConversationOccasionPack.PublishedSlice(
                presenceBubble: bubble,
                queued: model.queuedMessages,
                agents: bubble?.agents ?? [],
                lastSteerReceipt: model.lastSteerReceipt,
                latestSurfaceHandoff: model.latestSurfaceHandoff,
                changeReview: review,
                changeReviewLoadFinished: reviewFinished,
                drafts: model.drafts,
                uploadPercent: model.drafts.contains(where: {
                    if case .subindo = $0.state { return true }
                    return false
                }) ? model.uploadPercent : nil,
                effort: model.effort,
                cacheCapturedAt: model.cacheCapturedAt,
                draftText: model.draftText,
                isSending: model.isSending,
                artifacts: artifacts,
                artifactsBag: artifactsBag,
                turnCount: model.bubbles.count,
                toolbarMode: model.taskKind ?? "",
                toolbarWorkspaceName: model.workspacePath,
                hasLoadError: model.loadError != nil,
                workspaceCatalogCount: session.workspaces.count
            )
            return ConversationOccasionPack.facts(
                session: session,
                threadId: threadId,
                title: threadTitle,
                workspaceKey: model.workspacePath,
                published: published
            )
        }
    }
}

extension ConversationView {
    func presenceModifiers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { presenceOnAppear() }
            .onChange(of: model.threadId) { _, now in presenceOnThreadChange(now) }
            .onDisappear { presenceOnDisappear() }
    }
}
// MARK: - Chrome / header / sheets

// MARK: - Sheet / seal gates

extension ConversationView {
    /// Folhas de modo/esforço/fila/anexo/câmera/arquivo.
    var hasOpenComposerSheet: Bool {
        showModeSheet || showWorkspaceSheet || showEffortSheet
            || showQueueSheet || showAttachmentSheet || showCamera || showFileImporter
    }
}

extension ConversationView {
    /// Folhas de revisão/artefato/steer abertas pelo composer/cockpit.
    var hasOpenTraceSheet: Bool {
        reviewTrace != nil || artifactTrace != nil || steerTrace != nil
    }
}

extension ConversationView {
    @ViewBuilder
    var confirmingCacheSeal: some View {
        if readSealConfirming, let capturedAt = lastCacheCapturedAt {
            StaleReadSeal(capturedAt: capturedAt, confirming: true, reduceMotion: reduceMotion)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                .task {
                    if !reduceMotion { try? await Task.sleep(nanoseconds: 320_000_000) }
                    readSealConfirming = false
                }
        }
    }
}

// MARK: - Actions

extension ConversationView {
    func editAndResend(_ bubble: ChatBubble) {
        guard bubble.role == "user" else { return }
        model.updateDraft(bubble.text)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        focused = true
        setToast("mensagem no composer para novo turno")
    }

    func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        setToast("\(label) copiada")
    }
}

extension ConversationView {
    @ViewBuilder var handoffReceipt: some View {
        if let handoff = model.latestSurfaceHandoff {
            ConversationHandoffReceipt(handoff: handoff)
        }
    }
}

// MARK: - Header chrome

extension ConversationView {
    var header: some View {
        HStack(spacing: 12) {
            if hidesNavigationBack {
                Color.clear.frame(width: 40, height: 40)
            } else {
                headerBackButton
            }
            Spacer(minLength: 0)
            Text(title)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(title)
            Spacer(minLength: 0)
            headerTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }
}

extension ConversationView {
    var headerBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).atlasGlassCircle()
        }
        .accessibilityLabel(WorkspaceJudgment.backLabel)
        .accessibilityHint("fecha a conversa")
    }
}

extension ConversationView {
    @ViewBuilder
    var continuityMenuActions: some View {
        Button {
            Task { await model.handoffToSurface(.desktop) }
        } label: { Label("Continuar no Mac", systemImage: "desktopcomputer") }
        Button {
            Task { await model.handoffToSurface(.terminal) }
        } label: { Label("Continuar no Terminal", systemImage: "terminal") }
    }
}

extension ConversationView {
    var continuityMenuLabel: some View {
        Image(systemName: "ellipsis")
            .atlasSans(15, .semibold).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 40, height: 40).atlasGlassCircle()
    }
}

extension ConversationView {
    @ViewBuilder
    var continuityMenu: some View {
        Menu {
            continuityMenuActions
        } label: {
            continuityMenuLabel
        }
        .accessibilityLabel(ConversationMessagesJudgment.headerContinuityLabel)
        .accessibilityHint(ConversationMessagesJudgment.headerContinuityHint)
        .accessibilityIdentifier(A11yID.conversationHeaderContinuity)
    }
}

extension ConversationView {
    @ViewBuilder
    var outlineHeaderButton: some View {
        if !model.bubbles.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                showOutline = true
            } label: {
                Image(systemName: "list.bullet.rectangle")
                    .atlasSans(15, .semibold).foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 40, height: 40).atlasGlassCircle()
            }
            .accessibilityLabel(ConversationOutlineJudgment.spokenOutlineControl(turnCount: model.bubbles.count))
            .accessibilityHint(ConversationOutlineJudgment.outlineControlHint)
            .accessibilityIdentifier(A11yID.conversationOutline)
        }
    }
}

extension ConversationView {
    @ViewBuilder
    var headerTrailing: some View {
        if model.threadId != nil {
            HStack(spacing: 8) {
                outlineHeaderButton
                continuityMenu
            }
        } else {
            Color.clear.frame(width: 40, height: 40)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Toast

extension ConversationView {
    @ViewBuilder var toast: some View {
        if let t = model.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(ConversationMessagesJudgment.spokenToast(t))
                .accessibilityIdentifier(A11yID.conversationToast)
                .task { await dismissToastAfterDelay() }
        }
    }
}

extension ConversationView {
    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        clearToast()
    }
}

extension ConversationView {
    // MARK: - Cache seal

    @ViewBuilder var cacheAgeSeal: some View {
        if model.showingStaleCache, let capturedAt = model.cacheCapturedAt {
            StaleReadSeal(capturedAt: capturedAt, confirming: false, reduceMotion: reduceMotion)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        } else {
            confirmingCacheSeal
        }
    }
}
// MARK: - Composer wire

// MARK: - Composer wire

extension ConversationView {
    var conversationComposerSheetFlagBindings: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>
    ) {
        (
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            pickedPhoto: $pickedPhoto,
            showFileImporter: $showFileImporter,
            showCamera: $showCamera
        )
    }
}

extension ConversationView {
    var conversationComposerTraceBindings: (
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        (
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace
        )
    }
}

extension ConversationView {
    var conversationComposerSheetBindings: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        conversationComposerSheetTraceAggregate
    }
}

extension ConversationView {
    func conversationComposerInit(
        sessionArgs: (
            model: ConversationModel,
            session: AtlasSession,
            reduceMotion: Bool,
            focused: FocusState<Bool>.Binding
        ),
        bindings: (
            mode: Binding<String>,
            showModeSheet: Binding<Bool>,
            showWorkspaceSheet: Binding<Bool>,
            showEffortSheet: Binding<Bool>,
            showQueueSheet: Binding<Bool>,
            showAttachmentSheet: Binding<Bool>,
            pickedPhoto: Binding<PhotosPickerItem?>,
            showFileImporter: Binding<Bool>,
            showCamera: Binding<Bool>,
            reviewTrace: Binding<ConversationReviewTraceRef?>,
            artifactTrace: Binding<ConversationReviewTraceRef?>,
            steerTrace: Binding<ConversationSteerTraceRef?>
        )
    ) -> ConversationComposer {
        ConversationComposer(
            model: sessionArgs.model,
            session: sessionArgs.session,
            reduceMotion: sessionArgs.reduceMotion,
            focused: sessionArgs.focused,
            mode: bindings.mode,
            showModeSheet: bindings.showModeSheet,
            showWorkspaceSheet: bindings.showWorkspaceSheet,
            showEffortSheet: bindings.showEffortSheet,
            showQueueSheet: bindings.showQueueSheet,
            showAttachmentSheet: bindings.showAttachmentSheet,
            pickedPhoto: bindings.pickedPhoto,
            showFileImporter: bindings.showFileImporter,
            showCamera: bindings.showCamera,
            reviewTrace: bindings.reviewTrace,
            artifactTrace: bindings.artifactTrace,
            steerTrace: bindings.steerTrace
        )
    }
}

extension ConversationView {
    func conversationComposerSessionArgs(
        focused: FocusState<Bool>.Binding
    ) -> (
        model: ConversationModel,
        session: AtlasSession,
        reduceMotion: Bool,
        focused: FocusState<Bool>.Binding
    ) {
        (
            model: model,
            session: session,
            reduceMotion: reduceMotion,
            focused: focused
        )
    }
}

extension ConversationView {
    func conversationComposerCoreArgs(
        bindings: (
            mode: Binding<String>,
            showModeSheet: Binding<Bool>,
            showWorkspaceSheet: Binding<Bool>,
            showEffortSheet: Binding<Bool>,
            showQueueSheet: Binding<Bool>,
            showAttachmentSheet: Binding<Bool>,
            pickedPhoto: Binding<PhotosPickerItem?>,
            showFileImporter: Binding<Bool>,
            showCamera: Binding<Bool>,
            reviewTrace: Binding<ConversationReviewTraceRef?>,
            artifactTrace: Binding<ConversationReviewTraceRef?>,
            steerTrace: Binding<ConversationSteerTraceRef?>
        )
    ) -> ConversationComposer {
        conversationComposerInit(
            sessionArgs: conversationComposerSessionArgs(focused: $focused),
            bindings: bindings
        )
    }
}

extension ConversationView {
    var conversationComposerArgs: ConversationComposer {
        conversationComposerCoreArgs(bindings: conversationComposerSheetBindings)
    }
}

extension ConversationView {
    var conversationComposerCard: some View {
        conversationComposerArgs
    }
}
// MARK: - Messages wire

// MARK: - Messages wire

extension ConversationView {
    var conversationMessagesModelArgs: (
        model: ConversationModel,
        reduceMotion: Bool,
        emptyPrompt: String?,
        emptySuggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool
    ) {
        (
            model: model,
            reduceMotion: reduceMotion,
            emptyPrompt: emptyPrompt,
            emptySuggestions: emptySuggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: !session.workspaces.isEmpty
        )
    }
}

extension ConversationView {
    var conversationMessagesTraceArgs: (
        awayFromBottom: Binding<Bool>,
        lastScrollAt: Binding<CFAbsoluteTime>,
        lastScrollBubbleCount: Binding<Int>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onEditResend: (ChatBubble) -> Void,
        onCopy: (String, String) -> Void
    ) {
        (
            awayFromBottom: $awayFromBottom,
            lastScrollAt: $lastScrollAt,
            lastScrollBubbleCount: $lastScrollBubbleCount,
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace,
            onEditResend: editAndResend,
            onCopy: copy
        )
    }
}

extension ConversationView {
    var conversationMessagesView: some View {
        let modelArgs = conversationMessagesModelArgs
        let traceArgs = conversationMessagesTraceArgs
        return ConversationMessages(
            model: modelArgs.model,
            reduceMotion: modelArgs.reduceMotion,
            emptyPrompt: modelArgs.emptyPrompt,
            emptySuggestions: modelArgs.emptySuggestions,
            isHomePartida: modelArgs.isHomePartida,
            hasWorkspaces: modelArgs.hasWorkspaces,
            awayFromBottom: traceArgs.awayFromBottom,
            lastScrollAt: traceArgs.lastScrollAt,
            lastScrollBubbleCount: traceArgs.lastScrollBubbleCount,
            reviewTrace: traceArgs.reviewTrace,
            artifactTrace: traceArgs.artifactTrace,
            steerTrace: traceArgs.steerTrace,
            onEditResend: traceArgs.onEditResend,
            onCopy: traceArgs.onCopy
        )
    }
}

extension ConversationView {
    var conversationMessagesStack: some View {
        VStack(spacing: 0) {
            header
            cacheAgeSeal
            handoffReceipt
            conversationMessagesView
        }
    }
}

// MARK: - Continuity copy

func atlasSurfaceLabel(_ raw: String) -> String {
    switch raw {
    case "atlas_mobile": return "iPhone"
    case "atlas_desktop": return "Mac"
    case "atlas_terminal": return "Terminal"
    default: return raw
    }
}

func atlasHandoffStatusEditorial(_ status: String) -> String {
    switch status {
    case "ready": return "pronto"
    case "pending": return "enviando"
    default: return status
    }
}

func editorialThreadPrefix(_ threadId: String) -> String {
    let trimmed = threadId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 12 else { return trimmed }
    return String(trimmed.prefix(12)) + "…"
}

func atlasRelativeAgePT(since date: Date, now: Date = Date()) -> String {
    let seconds = max(0, Int(now.timeIntervalSince(date)))
    if seconds < 60 { return "menos de 1 min" }

    let minutes = seconds / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    if hours < 24 { return "\(hours)h" }

    let days = hours / 24
    return days == 1 ? "1 dia" : "\(days) dias"
}

// MARK: - Types

extension ChatBubble {
    var currentActivity: AtlasAgentActivity? { atlasCurrentAgentActivity(from: activities) }
}

extension ChatBubble {
    var hasLiveExecutionSurface: Bool {
        showsReconnectSurface
            || !activities.isEmpty
            || !agents.isEmpty
            || decideStrategy != nil
    }
}

extension ChatBubble {
    var executionPresence: AtlasExecutionPresence? {
        AtlasExecutionPresence(
            isExecuting: streaming,
            presentationState: executionPresentationState,
            currentActivity: currentActivity
        )
    }
}

struct ExecAgent: Equatable, Identifiable {
    let id: String
    let agent: String?     // orquestrador / atlas / …
    let provider: String?  // hermes_cli / claude_cli / …
    let model: String?     // claude-sonnet-4-6 / qwen3.6-27b / …
    let status: String     // queued / processing / succeeded / failed / …
}

extension FeedbackKind {
    var activeAction: String {
        switch self {
        case .util: return "useful"
        case .contexto: return "wrong_context"
        case .longo: return "too_long"
        case .fraco: return "weak"
        }
    }
}

extension FeedbackKind {
    var label: String {
        switch self {
        case .util: return "útil"
        case .contexto: return "contexto"
        case .longo: return "longo"
        case .fraco: return "fraco"
        }
    }
}

extension FeedbackKind {
    var payload: FeedbackAiInteractionInput {
        switch self {
        case .util:
            return .init(feedbackScore: 5, feedbackAction: "useful")
        case .contexto:
            return .init(feedbackScore: 1, feedbackAction: "wrong_context")
        case .longo:
            return .init(feedbackScore: 2, feedbackComment: "[too_long]")
        case .fraco:
            return .init(feedbackScore: 1, feedbackComment: "[weak]")
        }
    }
}

enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
}

struct LocalDraft: Identifiable, Equatable {
    enum State: Equatable { case pronto, subindo, falhou(String) }
    let id: String
    let fileName: String
    let mimeType: String
    let kind: AtlasAttachmentKind
    let bytes: Int
    let preview: Data?     // pequena o bastante pra UIImage(data:) direto
    var state: State = .pronto
}

struct ChatBubble: Identifiable, Equatable {
    let id: String
    let role: String
    var text: String
    var streaming: Bool = false
    var traceId: TraceID? = nil
    var occurredAt: String? = nil
    var provider: String? = nil
    var model: String? = nil
    var feedbackAction: String? = nil
    var startedAt: Date? = nil
    var elapsedMs: Int? = nil
    var agents: [ExecAgent] = []
    var decideStage: String? = nil
    var decideStrategy: String? = nil
    var activities: [AtlasAgentActivity] = []
    var reconnectNotice: String? = nil
    var decisionSummary: AtlasDecisionSummary? = nil
    var qualitySummary: AtlasQualitySummary? = nil
    var executionPlan: AtlasExecutionPlan? = nil
    var diffStats: AtlasTraceGovernance.DiffStats? = nil
    var planRevisions: [AtlasTraceGovernance.PlanRevision] = []
    var executionProgress: AtlasExecutionPlan.Progress? = nil
    var executionPresentationState: AtlasExecutionPresentationState? = nil
    var executionChoiceJobId: JobID? = nil
    var retryableJobId: JobID? = nil
}
