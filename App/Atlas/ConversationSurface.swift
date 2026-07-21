import SwiftUI
import AtlasCore
import PhotosUI

// IDLE-COMPRESS fused ConversationView · ConversationSurface.swift

// --- ConversationView+Init+ModelState.swift ---
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

// --- ConversationView+Init.swift ---


// --- ConversationView+InitSeed.swift ---
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

// --- ConversationView+InitSeedDraft.swift ---
extension ConversationView {
    static func seedDraft(on model: ConversationModel, draft: String) {
        guard !draft.isEmpty else { return }
        model.updateDraft(draft)
    }
}

// --- ConversationView+InitSeedWorkspace.swift ---
extension ConversationView {
    static func seedWorkspace(on model: ConversationModel, workspace: String?) {
        guard let workspace else { return }
        model.workspaceSlug = workspace
        model.workspaceName = workspace
    }
}

// --- ConversationView+Lifecycle+SendHaptic.swift ---
extension ConversationView {
    func applySendHaptic<Content: View>(_ content: Content) -> some View {
        content
            .onChange(of: model.isSending) { was, now in
                if was && !now { AtlasMotion.successNotification(reduceMotion: reduceMotion) }
            }
    }
}

// --- ConversationView+Lifecycle.swift ---
extension ConversationView {
    func conversationLifecycleModifiers<Content: View>(_ content: Content) -> some View {
        conversationOutlineSheet(
            conversationPresenceModifiers(
                applySendHaptic(
                    applyCacheLifecycleModifiers(content)
                        .task { await model.load() }
                )
            )
        )
    }
}

// --- ConversationView+LifecycleCache.swift ---
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

// --- ConversationView+LifecycleOutline.swift ---
extension ConversationView {
    func conversationOutlineSheet<Content: View>(_ content: Content) -> some View {
        content.sheet(isPresented: $showOutline) {
            ConversationOutlineSheet(bubbles: model.bubbles, reduceMotion: reduceMotion)
        }
    }
}

// --- ConversationView+LifecyclePresence+Appear.swift ---
extension ConversationView {
    func conversationPresenceOnAppear() {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: model.threadId)
        TurnPresence.shared.setVisible(model, visible: true)
        if startFocused && model.bubbles.isEmpty {
            // Espera a sheet assentar; 0.45 sentia lento demais.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { focused = true }
        }
    }
}

// --- ConversationView+LifecyclePresence+Disappear.swift ---
extension ConversationView {
    func conversationPresenceOnDisappear() {
        TurnPresence.shared.setVisible(model, visible: false)
        model.markThreadVisited()
    }
}

// --- ConversationView+LifecyclePresence+ThreadChange.swift ---
extension ConversationView {
    func conversationPresenceOnThreadChange(_ now: ThreadID?) {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
        TurnPresence.shared.setVisible(model, visible: true)
        if let now { onThread?(now) }
    }
}

// --- ConversationView+LifecyclePresence.swift ---
extension ConversationView {
    func conversationPresenceModifiers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { conversationPresenceOnAppear() }
            .onChange(of: model.threadId) { _, now in conversationPresenceOnThreadChange(now) }
            .onDisappear { conversationPresenceOnDisappear() }
    }
}

// --- ConversationView+PageComposerArgs+Bindings+Sheets.swift ---
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

// --- ConversationView+PageComposerArgs+Bindings+Trace.swift ---
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

// --- ConversationView+PageComposerArgs+Bindings.swift ---
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

// --- ConversationView+PageComposerArgs+Core+ComposerInit.swift ---
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

// --- ConversationView+PageComposerArgs+Core+Session.swift ---
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

// --- ConversationView+PageComposerArgs+Core.swift ---
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

// --- ConversationView+PageComposerArgs.swift ---
extension ConversationView {
    var conversationComposerArgs: ConversationComposer {
        conversationComposerCoreArgs(bindings: conversationComposerSheetBindings)
    }
}

// --- ConversationView+PageComposerCard.swift ---
extension ConversationView {
    var conversationComposerCard: some View {
        conversationComposerArgs
    }
}

// --- ConversationView+PageMessages+Model.swift ---
extension ConversationView {
    var conversationMessagesModelArgs: (
        model: ConversationModel,
        reduceMotion: Bool,
        emptyPrompt: String?,
        emptySuggestions: [String]?
    ) {
        (
            model: model,
            reduceMotion: reduceMotion,
            emptyPrompt: emptyPrompt,
            emptySuggestions: emptySuggestions
        )
    }
}

// --- ConversationView+PageMessages+Trace.swift ---
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

// --- ConversationView+PageMessages.swift ---
extension ConversationView {
    var conversationMessagesView: some View {
        let modelArgs = conversationMessagesModelArgs
        let traceArgs = conversationMessagesTraceArgs
        return ConversationMessages(
            model: modelArgs.model,
            reduceMotion: modelArgs.reduceMotion,
            emptyPrompt: modelArgs.emptyPrompt,
            emptySuggestions: modelArgs.emptySuggestions,
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

// --- ConversationView+PageParts.swift ---
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

// --- ConversationView+SheetFlags+Composer.swift ---
extension ConversationView {
    /// Folhas de modo/esforço/fila/anexo/câmera/arquivo.
    var hasOpenComposerSheet: Bool {
        showModeSheet || showWorkspaceSheet || showEffortSheet
            || showQueueSheet || showAttachmentSheet || showCamera || showFileImporter
    }
}

// --- ConversationView+SheetFlags+Trace.swift ---
extension ConversationView {
    /// Folhas de revisão/artefato/steer abertas pelo composer/cockpit.
    var hasOpenTraceSheet: Bool {
        reviewTrace != nil || artifactTrace != nil || steerTrace != nil
    }
}

// --- ConversationView+SheetFlags.swift ---


// --- ConversationViewChrome+ConfirmingSeal.swift ---
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

// --- ConversationViewChrome+EditCopy.swift ---
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

// --- ConversationViewChrome+Handoff.swift ---
extension ConversationView {
    @ViewBuilder var handoffReceipt: some View {
        if let handoff = model.latestSurfaceHandoff {
            ConversationHandoffReceipt(handoff: handoff)
        }
    }
}

// --- ConversationViewChrome+Header.swift ---
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

// --- ConversationViewChrome+HeaderBack.swift ---
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
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a conversa")
    }
}

// --- ConversationViewChrome+HeaderContinuity+MenuActions.swift ---
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

// --- ConversationViewChrome+HeaderContinuity+MenuLabel.swift ---
extension ConversationView {
    var continuityMenuLabel: some View {
        Image(systemName: "ellipsis")
            .atlasSans(15, .semibold).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 40, height: 40).atlasGlassCircle()
    }
}

// --- ConversationViewChrome+HeaderContinuity.swift ---
extension ConversationView {
    @ViewBuilder
    var continuityMenu: some View {
        Menu {
            continuityMenuActions
        } label: {
            continuityMenuLabel
        }
        .accessibilityLabel(ConversationViewA11y.headerContinuityLabel)
        .accessibilityHint(ConversationViewA11y.headerContinuityHint)
        .accessibilityIdentifier(A11yID.conversationHeaderContinuity)
    }
}

// --- ConversationViewChrome+HeaderOutline.swift ---
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
            .accessibilityLabel(ConversationViewA11y.spokenOutlineLabel(turnCount: model.bubbles.count))
            .accessibilityHint(ConversationViewA11y.outlineHint)
            .accessibilityIdentifier(A11yID.conversationOutline)
        }
    }
}

// --- ConversationViewChrome+HeaderTrailing.swift ---
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

// --- ConversationViewChrome+Toast.swift ---
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
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityIdentifier(A11yID.conversationToast)
                .task { await dismissToastAfterDelay() }
        }
    }
}

// --- ConversationViewChrome+ToastDismiss.swift ---
extension ConversationView {
    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        clearToast()
    }
}

// --- ConversationViewChrome.swift ---
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

