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

    func copyToClipboard(_ text: String, label: String) {
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
        .accessibilityLabel(WorkspaceJudgment.spokenBack)
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
            onCopy: copyToClipboard
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

// MARK: - ConversationOccasionPack

// MARK: - Conversation mid-thread occasion (WAVE-029)
// WAVE-171 density peel — host (slice + shell); Live/Organs peels.

/// Compiles turnFacts for an **open thread** — never Home partida.
/// Surface purity: `conversation` or `conversation.workspace`.
enum ConversationOccasionPack {

    static let invite = "continue nesta conversa"

    static var emptySuggestions: [String] {
        [
            "O que mudou neste fio?",
            "Resume o estado da execução",
            "O que preciso julgar agora?"
        ]
    }

    /// Live mid-thread slice from ConversationModel (WAVE-106).
    /// Never invent: only published bubble/queue/agents.
    /// Not Equatable: handoff DTO is Codable-only (no Core change).
    struct PublishedSlice {
        var presenceBubble: ChatBubble?
        var queued: [QueuedMessage]
        var agents: [ExecAgent]
        /// WAVE-160: last steer receipt from model (nil → absence).
        var lastSteerReceipt: AtlasInteractionSteerResponse? = nil
        /// WAVE-161: surface handoff receipt (nil → absence).
        var latestSurfaceHandoff: AtlasAiSurfaceHandoff? = nil
        /// WAVE-163: change review for presence trace (nil → absence).
        var changeReview: AtlasTraceChangeReview? = nil
        /// WAVE-163: whether review load finished for this trace.
        var changeReviewLoadFinished: Bool = false
        /// WAVE-164: composer draft strip + effort + cache seal.
        var drafts: [LocalDraft] = []
        var uploadPercent: Double? = nil
        var effort: AtlasComputeEffort = .auto
        var cacheCapturedAt: Date? = nil
        /// WAVE-178: send readiness (draft text + sending flag).
        var draftText: String = ""
        var isSending: Bool = false
        var artifacts: [AtlasTraceArtifacts.Item] = []
        /// WAVE-170: full artifacts bag when published for ArtifactJudgment.
        var artifactsBag: AtlasTraceArtifacts? = nil
        /// WAVE-166: outline turn count + toolbar chrome.
        var turnCount: Int = 0
        var toolbarMode: String = ""
        var toolbarWorkspaceName: String? = nil
        /// WAVE-168: messages load fail + presence + workspace catalog count.
        var hasLoadError: Bool = false
        var workspaceCatalogCount: Int = 0

        static let unbound = PublishedSlice(
            presenceBubble: nil,
            queued: [],
            agents: []
        )

        var hasModel: Bool { true }
    }

    /// Pure-ish compile from route + hub presence (casca only).
    /// `published` hydrates queue/plan/lanes/decision from the live model when bound.
    @MainActor
    static func facts(
        session: AtlasSession,
        threadId: ThreadID,
        title: String,
        workspaceKey: String? = nil,
        published: PublishedSlice? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        // WAVE-185: thread shell identity (one law).
        let shell = ConversationThreadShellJudgment.packFacts(
            session: session,
            threadId: threadId,
            title: title,
            workspaceKey: workspaceKey
        )
        facts.append(contentsOf: shell.facts)
        absences.append(contentsOf: shell.absences)
        let subject = shell.subject

        let matchingLive = appendLiveSessionFacts(
            session: session,
            threadId: threadId,
            into: &facts,
            anchors: &anchors,
            absences: &absences
        )

        // WAVE-084: mid-thread empty editorial (never Home catalog).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions,
            isHomePartida: false
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        let canDo = appendLiveOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )

        appendSteerHandoffReviewOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )
        appendComposerEvidenceOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )

        let surface: String
        if workspaceKey != nil {
            surface = "conversation.workspace"
        } else {
            surface = "conversation"
        }

        return AgenticOccasionPack(
            surface: surface,
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDo
        ).render()
    }

    /// Shared live-anchor line for Home/Workspace packs (face product words).
    static func liveAnchorLine(_ session: LiveSessionSnapshot) -> String {
        let face = ConversationExecutionPhase.face(for: session)
        let product = ConversationExecutionPhase.primaryProduct(face)
        return "live · \(session.title) · \(product)"
    }
}
extension ConversationOccasionPack {
    /// Matching live sessions + hub count. Returns matching list for later organs.
    @MainActor
    // MARK: - Live sessions
    static func appendLiveSessionFacts(
        session: AtlasSession,
        threadId: ThreadID,
        into facts: inout [String],
        anchors: inout [String],
        absences: inout [String]
    ) -> [LiveSessionSnapshot] {
        let matchingLive = TurnPresence.shared.liveSessions.filter { $0.threadId == threadId }
            + session.remoteLiveSessions.filter { $0.threadId == threadId }
        if matchingLive.isEmpty {
            facts.append("sessoes_vivas_deste_fio: 0")
        } else {
            facts.append("sessoes_vivas_deste_fio: \(matchingLive.count)")
            for s in matchingLive.prefix(4) {
                let face = ConversationExecutionPhase.face(for: s)
                let product = ConversationExecutionPhase.primaryProduct(face)
                anchors.append("live · \(s.title) · \(product)")
                if !s.phaseTitle.isEmpty {
                    facts.append("live_detail · \(s.title) · \(s.phaseTitle)")
                }
            }
        }
        let hubLive = TurnPresence.shared.liveSessions.count
        if hubLive > matchingLive.count {
            facts.append("sessoes_vivas_hub_global: \(hubLive) (outras conversas podem estar vivas)")
        }
        return matchingLive
    }

    /// Can-do · decision · queue · plan · lanes · strip. Returns canDo for render.
    @MainActor
    // MARK: - Live organs (can_do · strip)
    static func appendLiveOrgans(
        published: PublishedSlice?,
        matchingLive: [LiveSessionSnapshot],
        into facts: inout [String],
        absences: inout [String]
    ) -> AgenticOccasionPack.CanDo {
        let bubble = published?.presenceBubble
        let queued = published?.queued ?? []
        let agents = published?.agents
            ?? bubble?.agents
            ?? []
        let decisionRequired = bubble.map {
            ConversationDecisionJudgment.isDecisionRequired($0)
        } ?? false
        let decisionTitles = bubble.map {
            ConversationDecisionJudgment.choiceActions(for: $0).map(\.title)
        } ?? []
        let hasPlan = bubble?.executionPlan != nil
            || bubble?.executionProgress != nil

        if published == nil {
            absences.append("model mid-thread ainda não hidratado neste pack (session-only)")
        }

        let hasReviewControl = ChangeReviewControlJudgment.hasPublishedControlActions(
            from: published?.changeReview
        )
        let canSignals = ConversationCanDoJudgment.liveSignals(
            matchingLive: matchingLive,
            decisionRequired: decisionRequired,
            decisionActionTitles: decisionTitles,
            queueCount: queued.count,
            hasPlan: hasPlan,
            laneCount: agents.count,
            hasReviewControl: hasReviewControl
        )
        let canDoPack = ConversationCanDoJudgment.packFacts(canSignals)
        facts.append(contentsOf: canDoPack.facts)
        absences.append(contentsOf: canDoPack.absences)

        if let bubble {
            let decisionPack = ConversationDecisionJudgment.packFacts(from: bubble)
            facts.append(contentsOf: decisionPack.facts)
            absences.append(contentsOf: decisionPack.absences)
        } else {
            let decisionPack = ConversationDecisionJudgment.packFacts(
                decisionRequired: canSignals.hasDecision,
                actionTitles: canSignals.decisionActionTitles
            )
            facts.append(contentsOf: decisionPack.facts)
            absences.append(contentsOf: decisionPack.absences)
        }

        let queuePack = ComposerQueueJudgment.packFacts(from: queued)
        facts.append(contentsOf: queuePack.facts)
        absences.append(contentsOf: queuePack.absences)

        let planPack = PlanJudgment.packFacts(
            plan: bubble?.executionPlan,
            progress: bubble?.executionProgress
        )
        facts.append(contentsOf: planPack.facts)
        absences.append(contentsOf: planPack.absences)

        let lanesPack = ConversationAgentLanesJudgment.packFacts(from: agents)
        facts.append(contentsOf: lanesPack.facts)
        absences.append(contentsOf: lanesPack.absences)

        let stripFace: ConversationExecutionFace
        if let bubble {
            stripFace = ConversationExecutionPhase.face(for: bubble)
        } else {
            stripFace = matchingLive.first.map { ConversationExecutionPhase.face(for: $0) } ?? .quiet
        }
        let stripPack = ConversationLiveStripJudgment.packFacts(
            decisionRequired: canSignals.hasDecision,
            choiceActionCount: canSignals.decisionActionTitles.count,
            hasSteerHandler: canSignals.hasRunning || canSignals.hasPaused,
            face: stripFace,
            showsStop: bubble.map { ConversationExecutionPhase.stripShowsLiveChrome($0) }
                ?? (stripFace != .finished && stripFace != .quiet)
        )
        facts.append(contentsOf: stripPack.facts)
        absences.append(contentsOf: stripPack.absences)

        // WAVE-180: StateCard kind pack (strip phase alone is not enough).
        let statePack = ExecutionStateCardJudgment.packFacts(
            state: bubble?.executionPresentationState
        )
        facts.append(contentsOf: statePack.facts)
        absences.append(contentsOf: statePack.absences)

        // WAVE-174: timeline narrative + filter open recorte (chip filter is UI-local).
        let activities = bubble?.activities ?? []
        let narrativePack = LiveTimelineNarrativeJudgment.packFacts(from: activities)
        facts.append(contentsOf: narrativePack.facts)
        absences.append(contentsOf: narrativePack.absences)
        let filterPack = LiveTimelineFilterJudgment.packFactsOpenRecorte(
            totalSteps: activities.count
        )
        facts.append(contentsOf: filterPack.facts)
        absences.append(contentsOf: filterPack.absences)

        // Steer needs canSignals flags — keep here.
        if let traceId = bubble?.traceId {
            let steerPack = ConversationSteerJudgment.packFacts(
                instruction: "",
                scope: .currentStep,
                last: published?.lastSteerReceipt,
                traceId: traceId
            )
            facts.append(contentsOf: steerPack.facts)
            absences.append(contentsOf: steerPack.absences)
            absences.append("steer draft sheet-local — pack sem instrução até o modal")
        } else if canSignals.hasRunning || canSignals.hasPaused {
            absences.append("steer: sem traceId no presence bubble — não invente recibo")
        }

        return canDoPack.canDo
    }
}
extension ConversationOccasionPack {
    @MainActor
    // MARK: - Handoff · review · proof
    static func appendSteerHandoffReviewOrgans(
        published: PublishedSlice?,
        matchingLive: [LiveSessionSnapshot],
        into facts: inout [String],
        absences: inout [String]
    ) {
        let bubble = published?.presenceBubble

        let handoffPack = ConversationHandoffJudgment.packFacts(
            from: published?.latestSurfaceHandoff
        )
        facts.append(contentsOf: handoffPack.facts)
        absences.append(contentsOf: handoffPack.absences)

        if bubble?.traceId != nil {
            let sheetPack = ChangeReviewSheetJudgment.packFacts(
                loadFinished: published?.changeReviewLoadFinished ?? false,
                review: published?.changeReview
            )
            facts.append(contentsOf: sheetPack.facts)
            absences.append(contentsOf: sheetPack.absences)
            let riskPack = ChangeReviewJudgment.packFacts(from: published?.changeReview)
            facts.append(contentsOf: riskPack.facts)
            absences.append(contentsOf: riskPack.absences)
            // WAVE-175: assinatura run/file — availableActions · undecided · never NL apply.
            let controlPack = ChangeReviewControlJudgment.packFacts(
                from: published?.changeReview
            )
            facts.append(contentsOf: controlPack.facts)
            absences.append(contentsOf: controlPack.absences)
        }

        if let bubble {
            let proofPack = ExecutionProofJudgment.packFacts(
                bubble: bubble,
                artifactItems: published?.artifacts ?? []
            )
            facts.append(contentsOf: proofPack.facts)
            absences.append(contentsOf: proofPack.absences)
            let editorialPack = EditorialTurnJudgment.packFacts(
                provider: bubble.provider,
                model: bubble.model,
                elapsedMs: bubble.elapsedMs,
                feedbackAction: nil
            )
            facts.append(contentsOf: editorialPack.facts)
            absences.append(contentsOf: editorialPack.absences)
            // WAVE-174: structured markdown kinds from presence text (not full dump).
            let mdPack = AtlasMarkdownJudgment.packFacts(from: bubble.text)
            facts.append(contentsOf: mdPack.facts)
            absences.append(contentsOf: mdPack.absences)
        }
    }

    @MainActor
    // MARK: - Composer · evidence · messages
    static func appendComposerEvidenceOrgans(
        published: PublishedSlice?,
        matchingLive: [LiveSessionSnapshot],
        into facts: inout [String],
        absences: inout [String]
    ) {
        let bubble = published?.presenceBubble
        guard let published else { return }

        let draftPack = ComposerDraftJudgment.packFacts(
            drafts: published.drafts,
            uploadPercent: published.uploadPercent
        )
        facts.append(contentsOf: draftPack.facts)
        absences.append(contentsOf: draftPack.absences)
        // WAVE-178: gold CTA send face ≡ pack (never invent allows).
        let liveBubblePresent = bubble.map {
            ConversationExecutionPhase.stripShowsLiveChrome($0)
        } ?? false
        let sendPack = ComposerSendJudgment.packFacts(
            draftText: published.draftText,
            drafts: published.drafts,
            isSending: published.isSending,
            liveBubblePresent: liveBubblePresent
        )
        facts.append(contentsOf: sendPack.facts)
        absences.append(contentsOf: sendPack.absences)
        let effortPack = ComposerEffortJudgment.packFacts(effort: published.effort)
        facts.append(contentsOf: effortPack.facts)
        absences.append(contentsOf: effortPack.absences)
        let stalePack = ConversationStaleReadJudgment.packFacts(
            capturedAt: published.cacheCapturedAt
        )
        facts.append(contentsOf: stalePack.facts)
        absences.append(contentsOf: stalePack.absences)
        let artifactPack = ArtifactListJudgment.packFacts(
            items: published.artifacts,
            selectedID: nil
        )
        facts.append(contentsOf: artifactPack.facts)
        absences.append(contentsOf: artifactPack.absences)
        let artFacePack = ArtifactJudgment.packFacts(
            artifacts: published.artifactsBag,
            deliveryChecks: []
        )
        facts.append(contentsOf: artFacePack.facts)
        absences.append(contentsOf: artFacePack.absences)
        let evidencePack = TraceEvidenceJudgment.packFacts(
            isLoading: published.artifactsBag == nil && bubble?.traceId != nil,
            reason: published.artifactsBag == nil ? "artifacts_bag_nil" : nil
        )
        facts.append(contentsOf: evidencePack.facts)
        absences.append(contentsOf: evidencePack.absences)
        if !published.artifacts.isEmpty {
            let previewPack = ArtifactPreviewJudgment.packFacts(
                preview: .idle,
                selected: nil
            )
            facts.append(contentsOf: previewPack.facts)
            absences.append(contentsOf: previewPack.absences)
            absences.append("artifact_preview: face-only — seleção só no sheet de artefatos")
        }

        let outlinePack = ConversationOutlineJudgment.packFacts(turnCount: published.turnCount)
        facts.append(contentsOf: outlinePack.facts)
        absences.append(contentsOf: outlinePack.absences)
        let toolbarPack = ComposerToolbarJudgment.packFacts(
            mode: published.toolbarMode,
            workspaceName: published.toolbarWorkspaceName,
            effort: published.effort
        )
        facts.append(contentsOf: toolbarPack.facts)
        absences.append(contentsOf: toolbarPack.absences)

        let messagesPack = ConversationMessagesJudgment.packFacts(
            hasLoadError: published.hasLoadError,
            turnCount: published.turnCount
        )
        facts.append(contentsOf: messagesPack.facts)
        absences.append(contentsOf: messagesPack.absences)
        let presencePack = TurnPresenceJudgment.packFacts(
            presence: bubble?.executionPresence,
            liveSessionCount: matchingLive.count
        )
        facts.append(contentsOf: presencePack.facts)
        absences.append(contentsOf: presencePack.absences)
        let sheetPack = ComposerSheetJudgment.packFacts(
            modeKey: published.toolbarMode.isEmpty ? nil : published.toolbarMode,
            workspaceCount: published.workspaceCatalogCount,
            currentWorkspace: published.toolbarWorkspaceName
        )
        facts.append(contentsOf: sheetPack.facts)
        absences.append(contentsOf: sheetPack.absences)
    }
}

// MARK: - ConversationCockpit

// MARK: - Agent row

// MARK: - Host

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

// MARK: - Body / chrome

extension AgentRow {
    func agentRowChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.vertical, compactLane ? 3 : 0)
            .padding(.horizontal, compactLane ? 8 : 0)
            .background {
                if compactLane {
                    Capsule().fill(AtlasTheme.bgRecessed)
                }
            }
    }
}

extension AgentRow {
    @ViewBuilder
    var agentModelLabel: some View {
        if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
            Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
        }
    }
}

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }

    /// WAVE-027: face/attention vocabulary or silence — no parallel “processando” dialect.
    var statusWord: String? {
        ConversationExecutionPhase.agentStatusWord(rawStatus: agent.status)
    }
}

extension AgentRow {
    var agentRowContent: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
            // WAVE-049: label via lanes judgment (shared with pack).
            Text(ConversationAgentLanesJudgment.productLabel(for: agent))
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
            agentModelLabel
            Spacer()
            if let statusWord {
                Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(ConversationAgentLanesJudgment.productLabel(for: agent)), \(statusWord ?? agent.status)"
        )
    }
}

// MARK: - Strip

// MARK: - Host

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil
    /// WAVE-031: same path as StateCard — resolveExecutionChoice(jobId, optionId).
    var onChoose: ((JobID, String) -> Void)? = nil

    /// WAVE-023: strip branches on exclusive face (not bool soup alone).
    var face: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: bubble)
    }

    var decisionRequired: Bool {
        ConversationDecisionJudgment.isDecisionRequired(bubble)
    }

    var choiceActions: [AtlasExecutionPresentationState.Action] {
        ConversationDecisionJudgment.choiceActions(for: bubble)
    }

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            if ConversationExecutionPhase.stripShowsLiveChrome(bubble) || decisionRequired {
                stripActionButtons
            }
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.executionLiveStrip)
    }
}

// MARK: - Status

extension ExecutingStrip {
    // MARK: Status

    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            if face != .finished && face != .quiet {
                stripStatusMeta
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }

    @ViewBuilder
    var stripStatusLeading: some View {
        // Face reconnect (includes dual-surface primary ownership for WAVE-012).
        if face == .reconnect {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else if face == .paused {
            Text("‖")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        } else if face == .finished {
            Image(systemName: "checkmark")
                .atlasSans(10, .bold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var stripStatusTitle: some View {
        // WAVE-027/031: primary kicker = face/decision spoken; detail secondary.
        HStack(spacing: 6) {
            Text(ConversationExecutionPhase.primarySpoken(for: bubble))
                .font(AtlasFont.mono(11, .semibold))
                .foregroundStyle(
                    decisionRequired
                        ? AtlasTheme.accent
                        : (face == .quiet || face == .finished
                            ? AtlasTheme.textTertiary
                            : AtlasTheme.textSecondary)
                )
                .lineLimit(1)
                .layoutPriority(3)
                .accessibilityHidden(true)
            stripStatusDetail
        }
    }

    @ViewBuilder
    var stripStatusDetail: some View {
        switch face {
        case .reconnect:
            if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
                Text(line)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        case .multiAgent, .running:
            // WAVE-040: shared plan progress grammar with PlanCard.
            if bubble.executionPlan != nil || bubble.executionProgress != nil {
                Text(PlanJudgment.summaryLine(bubble: bubble))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            } else if let act = bubble.currentActivity {
                Text(act.title)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        case .finished, .paused, .quiet:
            EmptyView()
        }
    }

    @ViewBuilder
    var stripStatusMeta: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Actions

extension ExecutingStrip {
    // MARK: Actions

    @ViewBuilder
    var stripActionButtons: some View {
        // WAVE-031: elevate choice when published; stop/steer secondary.
        if decisionRequired, let jobId = bubble.executionChoiceJobId, let onChoose {
            if choiceActions.count == 1, let only = choiceActions.first {
                Button {
                    onChoose(jobId, only.id)
                } label: {
                    Text(ConversationDecisionJudgment.productStripChoose(
                        actionCount: 1,
                        firstTitle: only.title
                    ))
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                }
                .buttonStyle(PressableScale())
                .accessibilityIdentifier(A11yID.executionActionChoice(only.id))
                .accessibilityLabel(only.title)
                .accessibilityHint(ConversationLiveStripJudgment.spokenChooseConfirmHint())
            } else {
                Menu {
                    ForEach(choiceActions) { action in
                        Button(action.title) {
                            onChoose(jobId, action.id)
                        }
                    }
                } label: {
                    Text(ConversationDecisionJudgment.productStripChoose(
                        actionCount: choiceActions.count,
                        firstTitle: choiceActions.first?.title
                    ))
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                }
                .accessibilityLabel(ConversationDecisionJudgment.spokenLead)
                .accessibilityHint(ConversationLiveStripJudgment.spokenChooseMenuHint())
            }
        }
        if ConversationLiveStripJudgment.showsSteerCTA(
            decisionRequired: decisionRequired,
            hasSteerHandler: onSteer != nil
        ), let onSteer {
            Button(action: onSteer) {
                Text(ConversationLiveStripJudgment.steerButtonTitle)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ConversationLiveStripJudgment.spokenSteer())
            .accessibilityHint(ConversationLiveStripJudgment.spokenSteerHint())
        }
        Button(action: onStop) {
            Text(ConversationLiveStripJudgment.stopButtonTitle)
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(ConversationLiveStripJudgment.spokenStop())
        .accessibilityHint(ConversationLiveStripJudgment.spokenStopHint())
    }

    // MARK: A11y (phase-aligned compound label · WAVE-093)

    var stripAccessibilityLabel: String {
        ConversationLiveStripJudgment.spokenStrip(
            bubble: bubble,
            decisionRequired: decisionRequired,
            choiceActionCount: choiceActions.count,
            face: face,
            reconnectSpoken: face == .reconnect ? bubble.reconnectSpokenLabel : nil
        )
    }
}

// MARK: - Banners

struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var reduceMotion = false
    /// Quando o container pai compõe o spoken (reconexão, watchdog), o banner fica só visual.
    var embedInParent = false
    var accessibilityIdentifier: String?

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(11, .semibold)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
            Text(text)
                .font(AtlasFont.mono(10))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(tint.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(tint.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityHidden(embedInParent)
        .accessibilityLabel(ConversationLiveStripJudgment.spokenExecutionBanner(text))
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }

    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }

    var reconnectBannerIcon: String {
        executionPresentationState?.kind == .recovering
            ? "arrow.triangle.2.circlepath"
            : "wifi.exclamationmark"
    }

    /// Detalhe/checkpoint só do contrato de apresentação — nunca retry inventado.
    var reconnectSecondaryLines: [String] {
        guard streaming, executionPresentationState?.kind == .recovering else { return [] }
        var lines: [String] = []
        if reconnectNotice == nil, let detail = executionPresentationState?.detail {
            lines.append(detail)
        }
        if let checkpoint = executionPresentationState?.checkpoint {
            lines.append("checkpoint · \(checkpoint)")
        }
        return lines
    }

    var reconnectActiveTimerMs: Int? {
        guard streaming,
              executionPresentationState?.kind == .recovering,
              let timer = executionPresentationState?.timer
        else { return nil }
        return timer.elapsedActiveMilliseconds
    }

    var reconnectSpokenLabel: String {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}

struct ReconnectBanner: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        if bubble.showsReconnectSurface, let primary = bubble.reconnectPrimaryLine {
            VStack(alignment: .leading, spacing: 4) {
                ExecutionBanner(
                    text: primary,
                    icon: bubble.reconnectBannerIcon,
                    tint: AtlasTheme.textSecondary,
                    reduceMotion: reduceMotion,
                    embedInParent: true
                )
                ForEach(Array(bubble.reconnectSecondaryLines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityHidden(true)
                }
                if let ms = bubble.reconnectActiveTimerMs {
                    Text("ativo \(ExecutionStateCard.clock(ms))")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                        .modifier(NumericTextTransition(enabled: !reduceMotion))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(bubble.reconnectSpokenLabel)
            .accessibilityIdentifier(A11yID.executionReconnectBanner)
        }
    }
}

// ExecutionRibbon → ExecutionRibbon.swift (IDLE-COMPRESS)

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            silenceGate(now: context.date)
        }
    }

    @ViewBuilder
    private func silenceGate(now: Date) -> some View {
        if bubble.streaming,
           let silence = silenceSeconds(now: now),
           silence > 90 {
            Group {
                ExecutionBanner(
                    text: "Sem novos eventos há \(silence)s",
                    icon: "timer",
                    tint: AtlasTheme.domOperacional,
                    reduceMotion: reduceMotion,
                    embedInParent: true
                )
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ConversationLiveStripJudgment.spokenSilenceWatchdog(seconds: silence))
            .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
        }
    }

    private func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}
