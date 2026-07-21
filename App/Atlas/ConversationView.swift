import AtlasCore
import PhotosUI
import SwiftUI
import UIKit
import Foundation
import WidgetKit
import UniformTypeIdentifiers

// Cycle 044 fuse → ConversationView.swift

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

// O init voltou para ConversationView.swift: o backing `_model` de @State só é
// ModelState.

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

// A conversa — a base da comunicação. Metáfora de PÁGINA EDITORIAL, não bolhas
// SaaS: o turno do operador é uma citação com barra bronze; o do Atlas é uma
// página cheia (markdown editorial) com assinatura de provider, feedback
// governado e streaming vivo. Composer: ConversationComposer.swift.
// Turnos: ConversationMessages.swift. Folhas: ConversationSheets.swift.
// Chrome: ConversationViewChrome.swift · Init: ConversationView+Init.swift
// Lifecycle: ConversationView+Lifecycle.swift · Page: ConversationView+Page.swift
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @State var model: ConversationModel
    @State var mode = "geral"
    @State var showModeSheet = false
    @State var showWorkspaceSheet = false
    @State var showEffortSheet = false
    @State var showQueueSheet = false
    @State var showOutline = false
    @State var reviewTrace: ConversationReviewTraceRef?
    @State var artifactTrace: ConversationReviewTraceRef?
    @State var steerTrace: ConversationSteerTraceRef?
    @State var showAttachmentSheet = false
    @State var pickedPhoto: PhotosPickerItem?
    @State var showFileImporter = false
    @State var showCamera = false
    @FocusState var focused: Bool
    @State var awayFromBottom = false
    @State var readSealConfirming = false
    @State var lastCacheCapturedAt: Date?
    @State var lastScrollAt: CFAbsoluteTime = 0
    @State var lastScrollBubbleCount = 0

    let startFocused: Bool
    let emptyPrompt: String?
    let emptySuggestions: [String]?
    let onThread: ((ThreadID) -> Void)?
    /// Sheet do grafo: sem chevron — o gesto de arrastar fecha.
    let hidesNavigationBack: Bool

    var body: some View {
        conversationLifecycleModifiers(conversationPage)
    }

    init(
        client: AtlasClient,
        threadId: ThreadID?,
        title: String,
        emptyPrompt: String? = nil,
        emptySuggestions: [String]? = nil,
        taskKind: String? = nil,
        workspace: String? = nil,
        draft: String = "",
        turnFacts: ((String) async -> String?)? = nil,
        onThread: ((ThreadID) -> Void)? = nil,
        hidesNavigationBack: Bool = false
    ) {
        self.title = title
        self.startFocused = threadId == nil
        self.emptyPrompt = emptyPrompt
        self.emptySuggestions = emptySuggestions
        self.onThread = onThread
        self.hidesNavigationBack = hidesNavigationBack
        _model = Self.initModelState(
            client: client,
            threadId: threadId,
            taskKind: taskKind,
            workspace: workspace,
            draft: draft,
            turnFacts: turnFacts
        )
    }

}

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
            conversationPresenceModifiers(
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

extension ConversationView {
    func conversationPresenceOnDisappear() {
        TurnPresence.shared.setVisible(model, visible: false)
        model.markThreadVisited()
    }
}

extension ConversationView {
    func conversationPresenceOnThreadChange(_ now: ThreadID?) {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
        TurnPresence.shared.setVisible(model, visible: true)
        if let now { onThread?(now) }
    }
}

extension ConversationView {
    func conversationPresenceModifiers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { conversationPresenceOnAppear() }
            .onChange(of: model.threadId) { _, now in conversationPresenceOnThreadChange(now) }
            .onDisappear { conversationPresenceOnDisappear() }
    }
}

enum ConversationViewA11y {
    static func spokenToast(_ message: String) -> String { "Aviso, \(message)" }

    static func spokenOutlineLabel(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static let outlineHint = "Abre o índice editorial dos turnos desta conversa"
    static let headerContinuityLabel = "Continuidade da conversa"
    static let headerContinuityHint = "Continuar esta conversa no Mac ou no Terminal"
    static let screenHint = "Turnos e composer só com dados da sessão e do model"
}

extension ConversationView {
    func spokenConversationEmptyPrefix() -> String? {
        if model.loadError != nil, model.bubbles.isEmpty {
            return "\(title), falha ao carregar"
        }
        if model.bubbles.isEmpty {
            return "\(title), conversa vazia"
        }
        return nil
    }
}

extension ConversationView {
    func spokenConversationScreenLabel() -> String {
        if let empty = spokenConversationEmptyPrefix() { return empty }
        var parts = [title, "\(model.bubbles.count) turno\(model.bubbles.count == 1 ? "" : "s")"]
        if model.isSending { parts.append("enviando") }
        if model.showingStaleCache { parts.append("cache desatualizado") }
        return parts.joined(separator: ", ")
    }
}

extension ConversationView {
    func setToast(_ message: String) {
        if reduceMotion { model.toast = message }
        else { withAnimation(AtlasMotion.editorial) { model.toast = message } }
        UIAccessibility.post(notification: .announcement, argument: ConversationViewA11y.spokenToast(message))
    }

    func clearToast() {
        if reduceMotion { model.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { model.toast = nil } }
    }
}

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

// on ConversationView so bindings remain stable for modifiers.

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

extension ConversationView {
    func editAndResend(_ bubble: ChatBubble) {
        guard bubble.role == "user" else { return }
        // Soft owned by EditorialTurn button — avoid double fire.
        model.updateDraft(bubble.text)
        focused = true
        setToast("mensagem no composer para novo turno")
    }

    func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        // Success: copy completed (same class as markdown copy).
        AtlasMotion.successNotification(reduceMotion: reduceMotion)
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

extension ConversationView {
    var header: some View {
        VStack(spacing: 5) {
            HStack(spacing: 12) {
                if hidesNavigationBack {
                    Color.clear.frame(width: 48, height: 48)
                } else {
                    headerBackButton
                }
                Spacer(minLength: 0)
                Text(title)
                    .font(AtlasFont.serif(17, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(spokenConversationScreenLabel())
                    .accessibilityHint(
                        hidesNavigationBack
                            ? "arraste para baixo para fechar"
                            : ConversationViewA11y.screenHint
                    )
                Spacer(minLength: 0)
                headerTrailing
            }
            LinearGradient(
                colors: [
                    AtlasTheme.accent.opacity(0),
                    AtlasTheme.accent.opacity(0.5),
                    AtlasTheme.accent.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 48, height: 1.5)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }
}

extension ConversationView {
    var headerBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.accent.opacity(0.9))
                .frame(width: 48, height: 48).atlasGlassCircle().atlasElevation(radius: 6, y: 2, opacity: 0.14)
                .contentShape(Circle())
        }
        .accessibilityLabel("Voltar")
        .accessibilityHint("Fecha a conversa")
        .accessibilityAddTraits(.isButton)
    }
}

extension ConversationView {
    @ViewBuilder
    var continuityMenuActions: some View {
        Button {
            // Medium: governed surface handoff (Mac / Terminal).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            Task { await model.handoffToSurface(.desktop) }
        } label: { Label("Continuar no Mac", systemImage: "desktopcomputer") }
        .accessibilityLabel("Continuar no Mac")
        .accessibilityHint("Transfere esta sessão para o desktop")
        .accessibilityAddTraits(.isButton)
        Button {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            Task { await model.handoffToSurface(.terminal) }
        } label: { Label("Continuar no Terminal", systemImage: "terminal") }
        .accessibilityLabel("Continuar no Terminal")
        .accessibilityHint("Transfere esta sessão para o terminal")
        .accessibilityAddTraits(.isButton)
    }
}

extension ConversationView {
    var continuityMenuLabel: some View {
        Image(systemName: "ellipsis")
            .atlasSans(15, .semibold)
            .foregroundStyle(AtlasTheme.accent.opacity(0.88))
            .frame(width: 48, height: 48).atlasGlassCircle().atlasElevation(radius: 6, y: 2, opacity: 0.14)
            .contentShape(Circle())
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
        .accessibilityLabel(ConversationViewA11y.headerContinuityLabel)
        .accessibilityHint(ConversationViewA11y.headerContinuityHint)
        .accessibilityIdentifier(A11yID.conversationHeaderContinuity)
        .accessibilityAddTraits(.isButton)
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
                    .atlasSans(15, .semibold)
                    .foregroundStyle(AtlasTheme.accent.opacity(0.88))
                    .frame(width: 48, height: 48).atlasGlassCircle().atlasElevation(radius: 6, y: 2, opacity: 0.14)
                    .contentShape(Circle())
            }
            .accessibilityLabel(ConversationViewA11y.spokenOutlineLabel(turnCount: model.bubbles.count))
            .accessibilityHint(ConversationViewA11y.outlineHint)
            .accessibilityIdentifier(A11yID.conversationOutline)
            .accessibilityAddTraits(.isButton)
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
            Color.clear.frame(width: 48, height: 48)
                .accessibilityHidden(true)
        }
    }
}

extension ConversationView {
    @ViewBuilder var toast: some View {
        if let t = model.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .frame(minHeight: 48)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .atlasElevation(radius: 10, y: 3, opacity: 0.2)
                .padding(.top, 8)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityAddTraits(.updatesFrequently)
                .accessibilitySortPriority(12) // transient status over chrome
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

// Chrome extraído de ConversationView (Elite compressão).
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

extension ConversationView {
    @ViewBuilder
    var conversationPage: some View {
        conversationPageChrome(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()
                conversationMessagesStack
                conversationComposerBind
            }
        )
    }
}

extension ConversationView {
    func conversationPageChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .scrollDismissesKeyboard(.interactively)
            .accessibilityIdentifier(A11yID.conversationScreen)
            // Contain without fused screen label so messages/composer stay focusable.
            // Screen summary lives on the header title.
            .accessibilityElement(children: .contain)
            .overlay(alignment: .top) { toast }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.toast)
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
    var conversationComposerBind: some View {
        conversationComposerCard
    }
}

extension ConversationView {
    var conversationComposerSheetTraceAggregate: (
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
        let sheets = conversationComposerSheetFlagBindings
        let traces = conversationComposerTraceBindings
        return (
            mode: sheets.mode,
            showModeSheet: sheets.showModeSheet,
            showWorkspaceSheet: sheets.showWorkspaceSheet,
            showEffortSheet: sheets.showEffortSheet,
            showQueueSheet: sheets.showQueueSheet,
            showAttachmentSheet: sheets.showAttachmentSheet,
            pickedPhoto: sheets.pickedPhoto,
            showFileImporter: sheets.showFileImporter,
            showCamera: sheets.showCamera,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace
        )
    }
}

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


// Cycle 044 fuse → ConversationEmptyStates.swift

struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = a conversa do Atlas, que é sobre tudo.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    let onSuggestion: (String) -> Void
    @State var breathe = false

    var body: some View {
        heroStack
            .padding(.horizontal, 32).padding(.top, 56)
            .frame(maxWidth: .infinity)
            .onAppear { startBreathing() }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.conversationEmpty)
    }
}

/// Sugestões são convites reais de envio; glyph ✦ é decorativo.

enum EmptyConversationA11y {
    static func spokenPrompt(_ prompt: String?) -> String {
        let text = prompt?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let text, !text.isEmpty {
            return "conversa vazia, \(text)"
        }
        return "conversa vazia, o que você quer pensar agora?"
    }

    static func spokenSuggestion(_ text: String, index: Int, total: Int) -> String {
        "sugestão \(index + 1) de \(total), \(text)"
    }

    static let suggestionHint = "Envia esta pergunta agora"
}

extension EmptyConversation {
    func startBreathing() {
        if !reduceMotion {
            withAnimation(AtlasMotion.breath(2.2)) {
                breathe = true
            }
        }
    }
}

extension EmptyConversation {
    init(
        reduceMotion: Bool,
        prompt: String? = nil,
        suggestions: [String]? = nil,
        onSuggestion: @escaping (String) -> Void
    ) {
        self.reduceMotion = reduceMotion
        self.prompt = prompt
        self.suggestionsOverride = suggestions
        self.onSuggestion = onSuggestion
    }
}

extension EmptyConversation {
    var defaultSuggestions: [String] {
        [
            "O que está rodando no Atlas agora?",
            "Resuma meu dia até aqui",
            "Qual o status dos meus projetos?",
        ]
    }
}

extension EmptyConversation {
    var suggestions: [String] {
        suggestionsOverride ?? defaultSuggestions
    }

    var suggestionStack: some View {
        VStack(spacing: 10) {
            ForEach(Array(suggestions.enumerated()), id: \.element) { index, s in
                suggestionButton(s, index: index)
            }
        }
        .padding(.horizontal, 12)
    }
}

extension EmptyConversation {
    var heroGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(34)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(breathe ? 0.55 : 0.28), radius: breathe ? 12 : 5, y: 1)
            .scaleEffect(breathe ? 1.07 : 1).opacity(breathe ? 0.9 : 1)
            .accessibilityHidden(true)
    }
}

extension EmptyConversation {
    var heroPromptBlock: some View {
        Text("\u{201C}\(prompt ?? "O que você quer pensar agora?")\u{201D}")
            .font(AtlasFont.serifItalic(22)).lineSpacing(10)
            .multilineTextAlignment(.center)
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(EmptyConversationA11y.spokenPrompt(prompt))
            .accessibilityAddTraits(.isHeader)
    }
}

extension EmptyConversation {
    var heroStack: some View {
        VStack(spacing: 0) {
            heroGlyph
            Spacer().frame(height: 36)
            heroPromptBlock
            Spacer().frame(height: 40)
            suggestionStack
        }
    }
}

extension EmptyConversation {
    func suggestionButton(_ s: String, index: Int) -> some View {
        Button {
            // Medium: suggestion is a real send (same class as composer).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onSuggestion(s)
        } label: {
            Text(s)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textPrimary.opacity(0.92))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18).padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    Capsule().fill(AtlasTheme.surface.opacity(0.92))
                        .overlay(
                            Capsule().strokeBorder(
                                LinearGradient(
                                    colors: [
                                        AtlasTheme.accent.opacity(0.28),
                                        AtlasTheme.accent.opacity(0.08),
                                        AtlasTheme.separator
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                        )
                )
                .atlasElevation(radius: 8, y: 2, opacity: 0.14)
        }
        .buttonStyle(PressableScale())
        // Identifier = texto da sugestão (UITests + Voice Control estáveis).
        // Label falada leva o contexto "sugestão N de M".
        .accessibilityIdentifier(s)
        .accessibilityLabel(
            EmptyConversationA11y.spokenSuggestion(s, index: index, total: suggestions.count)
        )
        .accessibilityHint(EmptyConversationA11y.suggestionHint)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // empty suggestions are send-class
    }
}


// Cycle 044 fuse → ConversationChrome.swift

extension SheetShell {
    var sheetHandle: some View {
        // Soft gold-tinted grabber — quiet luxury, not pure slate bar.
        RoundedRectangle(cornerRadius: 3)
            .fill(AtlasTheme.accent.opacity(0.28))
            .frame(width: 42, height: 5)
            .padding(.top, 10).padding(.bottom, 16)
            .accessibilityHidden(true)
    }

    var sheetTitle: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            LinearGradient(
                colors: [
                    AtlasTheme.accent.opacity(0),
                    AtlasTheme.accent.opacity(0.5),
                    AtlasTheme.accent.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 56, height: 1.5)
            .accessibilityHidden(true)
        }
        .padding(.bottom, 14)
    }
}

extension SheetShell {
    func sheetPresentationChrome<Inner: View>(_ content: Inner) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .presentationDetents([.medium, .large])
            .presentationBackground(AtlasTheme.bg)
            .presentationDragIndicator(.hidden)
    }
}

extension SheetShell {
    var sheetScrollBody: some View {
        VStack(spacing: 0) {
            sheetHandle
            sheetTitle
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
    }
}

/// Rótulo composto só com label/sub publicados; seleção explícita.

enum SheetShellA11y {
    static func spokenRow(label: String, sub: String?, selected: Bool) -> String {
        var parts = [label]
        if let sub, !sub.isEmpty { parts.append(sub) }
        parts.append(selected ? "selecionado" : "disponível")
        return parts.joined(separator: ", ")
    }
}

// Shell compartilhado dos sheets do composer.

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        sheetPresentationChrome(sheetScrollBody)
    }
}

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
            Text("Novo desde a última visita")
                .font(AtlasFont.mono(10))
                .tracking(0.4)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("Novo desde a última visita")
        .accessibilityAddTraits([.isStaticText, .isHeader])
    }
}

enum ConversationOutlineA11y {
    static func spokenSheetLabel(turnCount: Int) -> String {
        guard turnCount > 0 else { return spokenEmptySheet() }
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }
}

extension ConversationOutlineSheet {
    func outlineA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.conversationOutlineSheet)
            .accessibilityLabel(ConversationOutlineA11y.spokenSheetLabel(turnCount: bubbles.count))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: bubbles.map(\.id))
    }
}

extension ConversationOutlineA11y {
    static func spokenSnippet(from text: String) -> String {
        ConversationOutlineA11ySnippet.spokenSnippet(from: text)
    }
}

extension ConversationOutlineA11y {
    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }
}

extension ConversationOutlineA11y {
    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        ConversationOutlineA11ySnippet.spokenRow(index: index, role: role, snippet: snippet)
    }
}

enum ConversationOutlineA11ySnippet {
    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(ConversationOutlineA11y.spokenRole(role)), \(snippet)"
    }
}

extension ConversationOutlineSheet {
    @ViewBuilder
    var outlineRowList: some View {
        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
            ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}

// MARK: - Índice da conversa

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        outlineA11yBind(
            SheetShell(title: "Índice da conversa") {
                if bubbles.isEmpty {
                    outlineEmpty
                } else {
                    outlineRowList
                }
            }
        )
    }
}

extension ConversationOutlineSheet {
    var outlineEmpty: some View {
        Text("Nenhum turno carregado nesta thread.")
            .font(AtlasFont.mono(11))
            // Soft gold-quiet empty outline meta.
            .foregroundStyle(AtlasTheme.accent.opacity(0.62))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .accessibilityLabel(ConversationOutlineA11y.spokenEmptySheet())
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.conversationOutlineEmpty)
    }
}

extension ConversationOutlineRow {
    var snippet: String {
        ConversationOutlineA11y.spokenSnippet(from: bubble.text)
    }

    var outlineLead: some View {
        outlineLeadMeta
    }
}

extension ConversationOutlineRow {
    var outlineLeadIndex: some View {
        Text(String(format: "%02d", index))
            .font(AtlasFont.mono(11, .medium))
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 32, height: 32)
            .background(Circle().fill(AtlasTheme.goldVeil))
            .overlay(Circle().stroke(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1))
            .atlasElevation(radius: 3, y: 1, opacity: 0.1)
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}

extension ConversationOutlineRow {
    var outlineLeadSnippetStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            outlineLeadRole
            Text(snippet)
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension ConversationOutlineRow {
    var outlineLeadMeta: some View {
        HStack(alignment: .center, spacing: 12) {
            outlineLeadIndex
            outlineLeadSnippetStack
            Spacer(minLength: 0)
        }
    }
}

extension ConversationOutlineRow {
    var outlineLeadRole: some View {
        Text(bubble.role == "user" ? "Você" : "Atlas")
            .font(AtlasFont.mono(10, .semibold))
            .foregroundStyle(
                bubble.role == "user"
                    ? AtlasTheme.textPrimary
                    : AtlasTheme.accent.opacity(0.9)
            )
            .accessibilityHidden(true)
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var body: some View {
        outlineLead
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 10)
            .frame(minHeight: 48, alignment: .center)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        AtlasTheme.accent.opacity(0),
                        AtlasTheme.accent.opacity(0.18),
                        AtlasTheme.separator,
                        AtlasTheme.accent.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.leading, AtlasTheme.Space.screen + 44)
            }
            .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                ConversationOutlineA11y.spokenRow(index: index, role: bubble.role, snippet: snippet)
            )
    }
}

extension ConversationHandoffReceipt {
    var accessibilitySummary: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment.map { ", há \($0)" } ?? ""
        if isReady {
            return "continuidade pronta no \(dest), mesma thread \(thread), sem prompt duplicado\(age)"
        }
        if isPending {
            return "continuidade enviando para o \(dest), mesma thread \(thread)\(age)"
        }
        return "recibo de continuidade para \(dest), \(atlasHandoffStatusEditorial(handoff.status)), thread \(thread)\(age)"
    }
}

extension ConversationHandoffReceipt {
    var handoffAgeFragment: String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date)
    }
}

extension ConversationHandoffReceipt {
    var headline: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        if isReady { return "Pronto no \(dest)" }
        if isPending { return "Enviando para o \(dest)…" }
        return "Continuidade para \(dest)"
    }
}

extension ConversationHandoffReceipt {
    var receiptCopy: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(headline)
                .font(AtlasFont.serif(13, .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subline)
                .font(AtlasFont.mono(10))
                // Soft gold-quiet handoff meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension ConversationHandoffReceipt {
    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .atlasSans(12, .semibold)
            // Soft gold-quiet pending spin; ready stays full accent.
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.55))
            .modifier(ReceiptSpinEffect(active: isPending && !reduceMotion))
            .accessibilityHidden(true)
    }
}

// iOS 17 compat: `.symbolEffect(.rotate,…)` exige iOS 18. Rotação contínua
// própria (deploymentTarget = iOS 17), respeitando Reduce Motion via `active`.
private struct ReceiptSpinEffect: ViewModifier {
    let active: Bool
    @State private var spinning = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active && spinning ? 360 : 0))
            .animation(active ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                       value: spinning)
            .onAppear { if active { spinning = true } }
            .onChange(of: active) { _, now in spinning = now }
    }
}

extension ConversationHandoffReceipt {
    var receiptRowHBox: some View {
        HStack(spacing: 9) {
            receiptRowLeading
            Spacer(minLength: 0)
        }
    }
}

extension ConversationHandoffReceipt {
    var receiptRowLayout: some View {
        receiptRowHBox
    }
}

extension ConversationHandoffReceipt {
    @ViewBuilder
    var receiptRowLeading: some View {
        receiptIcon
        receiptCopy
    }
}

extension ConversationHandoffReceipt {
    var receiptRowStack: some View {
        receiptRowLayout
    }
}

extension ConversationHandoffReceipt {
    func pendingSubline(route: String, thread: String, age: String?) -> String {
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}

extension ConversationHandoffReceipt {
    func readySubline(route: String, thread: String, age: String?) -> String {
        var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}

extension ConversationHandoffReceipt {
    var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment
        if isReady { return readySubline(route: route, thread: thread, age: age) }
        return pendingSubline(route: route, thread: thread, age: age)
    }
}

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        receiptChrome(receiptRowStack)
    }
}

extension ConversationHandoffReceipt {
    func receiptChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 48, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .fill(AtlasTheme.goldVeil)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .stroke(AtlasTheme.goldBorder, lineWidth: 1)
            )
            .atlasElevation(radius: 8, y: 2, opacity: 0.16)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 2)
            .padding(.bottom, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilitySummary)
            // Ready = landmark; pending live = updatesFrequently (respect Reduce Motion).
            .accessibilityAddTraits(handoffAccessibilityTraits)
            .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
    }

    var handoffAccessibilityTraits: AccessibilityTraits {
        if isReady { return [.isStaticText, .isHeader] }
        if isPending && !reduceMotion { return [.isStaticText, .updatesFrequently] }
        return .isStaticText
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealBody(now: Date) -> some View {
        sealChrome(now: now)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(StaleReadSealA11y.spokenLabel(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
    }
}

extension StaleReadSeal {
    func sealCaptionRow(now: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(StaleReadSealA11y.displayCaption(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
            .font(AtlasFont.mono(11))
            .modifier(NumericTextTransition(enabled: !reduceMotion && !confirming))
            .accessibilityHidden(true)
        }
        // Confirming sync flashes gold; steady age soft gold-quiet.
        .foregroundStyle(
            confirming
                ? AtlasTheme.accent.opacity(0.9)
                : AtlasTheme.accent.opacity(0.58)
        )
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealChrome(now: Date) -> some View {
        sealCaptionRow(now: now)
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(
                    confirming
                        ? AtlasTheme.goldVeil
                        : AtlasTheme.surface.opacity(0.35)
                )
            )
            .overlay(
                Capsule().stroke(
                    confirming ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft,
                    lineWidth: 1
                )
            )
            .atlasElevation(radius: 4, y: 1, opacity: confirming ? 0.12 : 0.06)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.95 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: AtlasMotion.considered) : nil, value: confirming)
    }
}

enum StaleReadSealA11y {
    static func spokenLabel(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion
                ? "Histórico salvo atualizado"
                : "Histórico salvo atualizado após sincronizar"
        }
        return "Histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}

extension StaleReadSealA11y {
    static func displayCaption(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealTimelineGate(now: Date) -> some View {
        if reduceMotion || confirming {
            sealBody(now: now)
        } else {
            TimelineView(.periodic(from: Date(), by: 60)) { context in
                sealBody(now: context.date)
            }
        }
    }
}

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        sealTimelineGate(now: Date())
            .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
            .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}

// Receipt/seals: ConversationChromeSheets+Receipt.swift

extension ComposerAttachmentsSheet {
    var attachmentsSheetChrome: some View {
        SheetShell(title: "Adicionar") {
            attachmentOptions
        }
        .accessibilityIdentifier(A11yID.attachmentsSheet)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenSheet)
        .accessibilityHint(ComposerAttachmentsA11y.spokenSheetHint)
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                dismiss()
            }
        }
    }
}

extension ComposerAttachmentsSheet {
    var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

    @ViewBuilder var attachmentOptions: some View {
        attachmentPhotoOptions
        attachmentFileAndPaste
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonA11y<V: View>(_ button: V) -> some View {
        button
            .disabled(pasteboardText == nil)
            .accessibilityLabel(ComposerAttachmentsA11y.spokenPaste(hasText: pasteboardText != nil))
            .accessibilityHint(pasteboardText == nil
                ? ComposerAttachmentsA11y.spokenPasteDisabledHint
                : ComposerAttachmentsA11y.spokenPasteHint)
            .accessibilityIdentifier(A11yID.attachmentPaste)
            .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonAction() {
        guard let text = pasteboardText else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in onPaste(text) }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileOption: some View {
        Button { choose(onChooseFile) } label: {
            ComposerAttachmentRow(icon: "doc", title: "Arquivo", subtitle: "PDF, texto, código ou dados")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenFile)
        .accessibilityHint(ComposerAttachmentsA11y.spokenFileHint)
        .accessibilityIdentifier(A11yID.attachmentFile)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileAndPaste: some View {
        attachmentFileOption
        pasteButton
    }

    func choose(_ action: @escaping @MainActor () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in action() }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        pasteButtonA11y(
            Button {
                pasteButtonAction()
            } label: {
                pasteButtonLabel
            }
            .buttonStyle(.plain)
        )
    }
}

extension ComposerAttachmentsSheet {
    var pasteButtonLabel: some View {
        ComposerAttachmentRow(
            icon: "doc.on.clipboard",
            title: "Colar contexto",
            subtitle: pasteboardText == nil
                ? "Nada na área de transferência"
                : "Adicionar texto da área de transferência"
        )
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentCameraOption: some View {
        Button { choose(onChooseCamera) } label: {
            ComposerAttachmentRow(icon: "camera", title: "Câmera", subtitle: "Capturar agora")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(CameraPickerA11y.spokenChooseCamera)
        .accessibilityHint(CameraPickerA11y.spokenChooseCameraHint)
        .accessibilityIdentifier(A11yID.cameraPicker)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOption: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ComposerAttachmentRow(icon: "photo", title: "Foto", subtitle: "Escolher da biblioteca")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPhoto)
        .accessibilityHint(ComposerAttachmentsA11y.spokenPhotoHint)
        .accessibilityIdentifier(A11yID.attachmentPhoto)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOptions: some View {
        attachmentPhotoOption
        attachmentCameraOption
    }
}

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado.
struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        attachmentsSheetChrome
    }
}

extension ComposerAttachmentRow {
    var attachmentRowIcon: some View {
        Image(systemName: icon)
            .atlasSans(15, .medium)
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 36, height: 36)
            .background(Circle().fill(AtlasTheme.goldVeil))
            .overlay(Circle().stroke(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1))
            .atlasElevation(radius: 4, y: 1, opacity: 0.1)
            .accessibilityHidden(true)
    }
}

extension ComposerAttachmentRow {
    var attachmentRowTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            // Soft gold-quiet attachment subtitle.
            Text(subtitle).atlasSans(13).foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .accessibilityHidden(true)
        }
    }
}

extension ComposerAttachmentRow {
    var attachmentRowCopy: some View {
        HStack(spacing: 14) {
            attachmentRowIcon
            attachmentRowTextStack
            Spacer()
            Image(systemName: "chevron.right")
                .atlasSans(12, .semibold)
                .foregroundStyle(AtlasTheme.accent.opacity(0.42))
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .frame(minHeight: 56)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            // Gold-quiet hairline family (home sectionLabel / Autônomos map).
            LinearGradient(
                colors: [
                    AtlasTheme.accent.opacity(0),
                    AtlasTheme.accent.opacity(0.22),
                    AtlasTheme.separator,
                    AtlasTheme.accent.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.leading, 24)
        }
    }
}

struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        attachmentRowCopy
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title), \(subtitle)")
    }
}

enum ComposerSheetA11y {}

extension ComposerSheetA11y {
    static let modeSheetHint = "Escolhe um rótulo local; não altera o turno ainda"
    static let effortSheetHint = "Escolhe o esforço computacional do próximo envio"
    static let workspaceSheetHint = "Escolhe a pasta do próximo envio entre as conversas carregadas"
}

extension ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }
}

extension ComposerSheetA11y {
    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"
}

extension ModeSheet {
    var modeFootnote: some View {
        Text(ComposerSheetA11y.modeFootnote)
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.accent.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

extension ModeSheet {
    var modeRows: some View {
        ForEach(Self.modes, id: \.0) { key, label in
            let isSelected = key == selected
            SheetRow(
                label: label,
                sub: ComposerSheetA11y.modeFootnote,
                selected: isSelected,
                accessibilityLabel: ComposerSheetA11y.modeLabel(key, title: label, selected: isSelected),
                accessibilityIdentifier: A11yID.modeRow(key)
            ) {
                // Soft owned by SheetRow — avoid double fire.
                selected = key
                dismiss()
            }
        }
    }
}

extension ModeSheet {
    static let modes = [
        ("geral", "Geral"),
        ("operacional", "Operacional"),
        ("autônomos", "Autônomos"),
        ("programação", "Programação"),
    ]
}

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                workspaceEmptyLabel
            } else {
                workspaceList
            }
        }
        .accessibilityIdentifier(A11yID.workspaceSheet)
        .accessibilityLabel("Workspace da conversa")
        .accessibilityHint(ComposerSheetA11y.workspaceSheetHint)
    }
}

extension WorkspaceSheet {
    var workspaceEmptyLabel: some View {
        Text("Nenhum workspace nas conversas carregadas")
            .atlasSans(15)
            // Soft gold-quiet empty sheet meta.
            .foregroundStyle(AtlasTheme.accent.opacity(0.62))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .accessibilityLabel(ComposerSheetA11y.workspaceEmpty)
    }
}

extension WorkspaceSheet {
    var workspaceListHeader: some View {
        Text("Pastas das conversas carregadas · vale no próximo envio")
            .atlasSans(12)
            // Soft gold-quiet workspace sheet caption.
            .foregroundStyle(AtlasTheme.accent.opacity(0.65))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityAddTraits(.isHeader)
    }

    func workspaceCountLine(_ count: Int) -> String {
        count == 1 ? "1 conversa carregada" : "\(count) conversas carregadas"
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        workspaceListHeader
        ForEach(workspaces) { ws in
            workspaceRow(ws)
        }
    }
}

extension WorkspaceSheet {
    func workspaceRowPick(_ ws: Workspace) {
        // Soft owned by SheetRow — avoid double fire.
        onPick(ws)
        dismiss()
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRowBuild(_ ws: Workspace, isSelected: Bool) -> some View {
        SheetRow(
            label: ws.name,
            sub: workspaceCountLine(ws.count),
            selected: isSelected,
            accessibilityLabel: ComposerSheetA11y.workspaceLabel(
                name: ws.name, count: ws.count, selected: isSelected
            ),
            accessibilityIdentifier: A11yID.workspaceRow(ws.id)
        ) {
            workspaceRowPick(ws)
        }
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRow(_ ws: Workspace) -> some View {
        workspaceRowBuild(ws, isSelected: ws.name == current)
    }
}

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) var dismiss  // interno: peels em outros arquivos usam
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Modo") {
            modeFootnote
            modeRows
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel("Modo da conversa")
        .accessibilityHint(ComposerSheetA11y.modeSheetHint)
    }
}

extension ComposerSheetA11y {
    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenEffort(effort)), \(state)"
    }
}

extension ComposerSheetA11y {
    static func spokenEffortLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        default: return nil
        }
    }
}

extension ComposerSheetA11y {
    static func spokenEffort(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLight(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático"
        }
    }
}

extension ComposerSheetA11y {
    static func effortSubtitleLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        default: return nil
        }
    }
}

extension ComposerSheetA11y {
    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        if let light = effortSubtitleLight(effort) { return light }
        switch effort {
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        default: return "Atlas Decide escolhe; nada vai no payload"
        }
    }
}

extension EffortSheet {
    func effortA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.effortSheet)
            .accessibilityLabel("Esforço computacional")
            .accessibilityHint(ComposerSheetA11y.effortSheetHint)
    }
}

extension EffortSheet {
    var effortFootnoteCopy: some View {
        Text("Vale para o próximo envio; automático deixa o Atlas Decide escolher")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.accent.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

extension EffortSheet {
    func pick(_ effort: AtlasComputeEffort) {
        // Persistência é do MODEL (boundary): a View nunca toca storage.
        // Soft owned by SheetRow — avoid double fire.
        model.setEffort(effort)
        dismiss()
    }
}

extension EffortSheet {
    var effortRows: some View {
        ForEach(AtlasComputeEffort.allCases, id: \.self) { effort in
            let selected = effort == model.effort
            SheetRow(
                label: effort.shortLabel.capitalized,
                sub: ComposerSheetA11y.effortSubtitle(effort),
                selected: selected,
                accessibilityLabel: ComposerSheetA11y.effortLabel(effort, selected: selected),
                accessibilityIdentifier: A11yID.effortRow(effort.rawValue)
            ) {
                pick(effort)
            }
        }
    }
}

extension EffortSheet {
    @ViewBuilder
    var effortSheetContent: some View {
        effortFootnoteCopy
        effortRows
    }
}

struct EffortSheet: View {
    var model: ConversationModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        effortA11yBind(
            SheetShell(title: "Esforço") {
                effortSheetContent
            }
        )
    }
}

struct SheetRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let label: String
    var sub: String? = nil
    let selected: Bool
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    var body: some View {
        sheetRowA11y
    }
}

extension SheetRow {
    var sheetRowA11y: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            rowLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            accessibilityLabel ?? SheetShellA11y.spokenRow(label: label, sub: sub, selected: selected)
        )
        .atlasAccessibilityHint(accessibilityHint)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .atlasAccessibilityIdentifier(accessibilityIdentifier)
        .overlay(alignment: .bottom) { sheetRowDivider }
    }
}

extension SheetRow {
    var sheetRowDivider: some View {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0),
                AtlasTheme.accent.opacity(0.18),
                AtlasTheme.separator,
                AtlasTheme.accent.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.leading, 24)
    }
}

extension SheetRow {
    var sheetRowLeading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .atlasSans(17, selected ? .semibold : .regular)
                .foregroundStyle(selected ? AtlasTheme.accent : AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let sub {
                // Soft gold-quiet sheet row caption.
                Text(sub).atlasSans(13).foregroundStyle(AtlasTheme.accent.opacity(0.62))
                    .accessibilityHidden(true)
            }
        }
    }
}

extension SheetRow {
    @ViewBuilder
    var sheetRowTrailing: some View {
        if selected {
            Image(systemName: "checkmark")
                .atlasSans(14, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 28, height: 28)
                .background(Circle().fill(AtlasTheme.goldVeil))
                .overlay(Circle().stroke(AtlasTheme.goldBorder.opacity(0.6), lineWidth: 1))
                .atlasElevation(radius: 3, y: 1, opacity: 0.1)
                .accessibilityHidden(true)
        }
    }
}

extension SheetRow {
    var rowLabel: some View {
        HStack(spacing: 12) {
            sheetRowLeading
            Spacer()
            sheetRowTrailing
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .frame(minHeight: 48)
        .background(selected ? AtlasTheme.goldVeil.opacity(0.55) : Color.clear)
        .contentShape(Rectangle())
    }
}


// Cycle 044 fuse → AtlasCloseToolbarButton.swift

struct AtlasCloseToolbarButton: View {
    var title: String = "Fechar"
    let spokenLabel: String
    var spokenHint: String = ""
    var accessibilityID: String? = nil
    let reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(title) {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }
        // Dispensar nunca é acento: Fechar/Cancelar fala ink neutro (canon §C).
        .tint(AtlasTheme.textSecondary)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint(spokenHint)
        .accessibilityAddTraits(.isButton)
        .modifier(CloseToolbarA11yID(accessibilityID))
    }
}

struct CloseToolbarA11yID: ViewModifier {
    let id: String?
    init(_ id: String?) { self.id = id }
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}

/// Colar só quando há texto real na área de transferência; câmera reusa CameraPickerA11y.

enum ComposerAttachmentsA11y {
    static let spokenSheet = "Adicionar anexo à mensagem"
    static let spokenSheetHint = "Foto, câmera, arquivo ou texto colado no próximo envio"
}

extension ComposerAttachmentsA11y {
    static let spokenPhoto = "Escolher foto da biblioteca"
    static let spokenPhotoHint = "Abre a biblioteca de fotos; nada é anexado até escolher"

    static let spokenFile = "Escolher arquivo"
    static let spokenFileHint = "PDF, texto, código ou dados do dispositivo"
}

extension ComposerAttachmentsA11y {
    static func spokenPaste(hasText: Bool) -> String {
        hasText
            ? "colar contexto da área de transferência"
            : "colar indisponível, área de transferência vazia"
    }

    static let spokenPasteHint = "Adiciona o texto copiado como contexto da mensagem"
    static let spokenPasteDisabledHint = "Copie texto antes de colar como contexto"
}


// Cycle 044 fuse → ConversationComposer.swift

struct ConversationComposer: View {
    var model: ConversationModel
    var session: AtlasSession
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding

    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var showFileImporter: Bool
    @Binding var showCamera: Bool
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?

    var body: some View {
        composerShell
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerShellPadding: some View {
        composerShellVBox
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.considered), value: model.isSending)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
            .background(composerFadeBackground)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerShellVBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
    }
}

extension ConversationComposer {
    var composerShell: some View {
        composerShellPadding
    }
}

extension ConversationComposer {
    @ViewBuilder var composerSurface: some View {
        if expanded || liveBubble != nil {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AtlasTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        // Soft gold-quiet expanded composer rim.
                        .strokeBorder(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1)
                )
                .atlasElevation(radius: 12, y: 4, opacity: 0.16)
        } else {
            Capsule(style: .continuous)
                .fill(AtlasTheme.surface)
                .overlay(
                    Capsule(style: .continuous)
                        // Soft gold-quiet collapsed invite rim — match AgenticPill.
                        .strokeBorder(AtlasTheme.goldBorder.opacity(0.5), lineWidth: 1)
                )
                // Collapsed invite shares floating plane with home AgenticPill.
                .atlasElevation(radius: 10, y: 3, opacity: 0.14)
        }
    }
}

extension ConversationComposer {
    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar (a fileira de controles só existia
    // com o teclado aberto). Estado de composição ⊃ estado de foco.
    var expanded: Bool { focused.wrappedValue || !model.drafts.isEmpty }

    /// Turno vivo (streaming) — dirige a faixa de execução dentro do composer.
    var liveBubble: ChatBubble? { model.bubbles.last(where: { $0.streaming }) }
}

extension ConversationComposer {
    var composerFadeBackground: some View {
        LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

extension ConversationComposer {
    func dismissKeyboard() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        if reduceMotion {
            focused.wrappedValue = false
        } else {
            withAnimation(AtlasMotion.arrival) { focused.wrappedValue = false }
        }
    }
}

extension ConversationComposer {
    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }
}

enum ConversationComposerA11y {
    static func spokenCard(expanded: Bool, draftCount: Int, queueCount: Int, isSending: Bool) -> String {
        var parts = ["compositor"]
        if expanded { parts.append("expandido") }
        if draftCount > 0 {
            parts.append("\(draftCount) anexo\(draftCount == 1 ? "" : "s")")
        }
        if queueCount > 0 {
            parts.append("\(queueCount) na fila")
        }
        if isSending { parts.append("enviando") }
        return parts.joined(separator: ", ")
    }

    static let cardHint = "Escreve, anexa e envia; fila e execução viva aparecem quando publicadas"
}

extension ConversationComposer {
    var composerCardSpokenLabel: String {
        ConversationComposerA11y.spokenCard(
            expanded: expanded,
            draftCount: model.drafts.count,
            queueCount: model.queuedMessages.count,
            isSending: model.isSending
        )
    }
}

extension ConversationComposer {
    var composerCardSurface: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            composerCardBody
        }
        .padding(composerCardPadding)
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82), value: model.drafts)
        // Contain without fused label: input/send/attach stay individually focusable.
        .accessibilityElement(children: .contain)
        .accessibilityHint(ConversationComposerA11y.cardHint)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerAttachmentOnly: some View {
        composerAttachmentStrip
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerToolbarOnly: some View {
        ComposerToolbar(
            model: model,
            reduceMotion: reduceMotion,
            focused: focused,
            expanded: expanded,
            mode: mode,
            liveBubble: liveBubble,
            onAttach: { showAttachmentSheet = true },
            onShowWorkspace: { showWorkspaceSheet = true },
            onShowMode: { showModeSheet = true },
            onShowEffort: { showEffortSheet = true },
            onSend: send
        )
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerStripToolbar: some View {
        composerAttachmentOnly
        composerToolbarOnly
    }
}

// Keyboard grabber — morto. Teclado dispensa no scroll / gesto da sheet.
// (A barra "fechar" lia como chrome de card e quebrava a pílula do grafo.)

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyGrabber: some View {
        EmptyView()
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyLive: some View {
        liveExecutionSection
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyQueue: some View {
        queueChipSection
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyStrip: some View {
        composerStripToolbar
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBody: some View {
        composerCardBodyLive
        composerCardBodyQueue
        composerCardBodyGrabber
        composerCardBodyStrip
    }
}

extension ConversationComposer {
    var composerCardSheetFlagArgs: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>
    ) {
        (
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto
        )
    }
}

extension ConversationComposer {
    var composerCardSheetTraceArgs: (
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

extension ConversationComposer {
    func composerCardSheets<V: View>(_ card: V) -> some View {
        let flags = composerCardSheetFlagArgs
        let traces = composerCardSheetTraceArgs
        return card.conversationComposerSheets(
            model: model,
            session: session,
            mode: flags.mode,
            showModeSheet: flags.showModeSheet,
            showWorkspaceSheet: flags.showWorkspaceSheet,
            showEffortSheet: flags.showEffortSheet,
            showQueueSheet: flags.showQueueSheet,
            showAttachmentSheet: flags.showAttachmentSheet,
            showCamera: flags.showCamera,
            showFileImporter: flags.showFileImporter,
            pickedPhoto: flags.pickedPhoto,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}

extension ConversationComposer {
    var composerCardPadding: EdgeInsets {
        expanded
            ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
}

extension ConversationComposer {
    var composerAttachmentStrip: some View {
        AttachmentStrip(
            drafts: model.drafts,
            reduceMotion: reduceMotion,
            uploadPercent: model.uploadPercent,
            onRemove: { model.removeDraft($0) },
            onFailedTap: { model.toast = $0 }
        )
    }
}

extension ConversationComposer {
    var composerCard: some View {
        composerCardSheets(composerCardSurface)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var queueChipSection: some View {
        if !model.queuedMessages.isEmpty {
            queueChipA11y(queueChipButton)
        }
    }
}

extension ConversationComposer {
    @ViewBuilder
    func queueChipA11y<V: View>(_ button: V) -> some View {
        button
            .padding(.bottom, expanded ? 0 : 8)
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityLabel(queueAccessibilityLabel)
            .accessibilityHint("Abre a folha para enviar agora ou remover da fila")
            .accessibilityIdentifier(A11yID.queueChip)
            .accessibilityAddTraits(.isButton)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var queueChipButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            showQueueSheet = true
        } label: {
            queueChipLabelView
        }
        .buttonStyle(PressableScale())
    }
}

extension ConversationComposer {
    var queueChipLabel: String {
        let n = model.queuedMessages.count
        return n == 1 ? "Fila · 1" : "Fila · \(n)"
    }

    var queueAccessibilityLabel: String {
        let n = model.queuedMessages.count
        return n == 1
            ? "1 mensagem na fila durante a execução"
            : "\(n) mensagens na fila durante a execução"
    }
}

extension ConversationComposer {
    var queueChipLabelView: some View {
        Text(queueChipLabel)
            .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .frame(minHeight: 48)
            .contentShape(Capsule())
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .atlasElevation(radius: 6, y: 2, opacity: 0.14)
    }
}

extension ConversationComposer {
    var keyboardGrabberBar: some View {
        // Match SheetShell grabber tone — gold-quiet, not slate-only.
        RoundedRectangle(cornerRadius: 3)
            .fill(AtlasTheme.accent.opacity(0.28))
            .frame(width: 42, height: 5)
            .frame(maxWidth: .infinity, minHeight: 48) // HIG hit target for dismiss
            .contentShape(Rectangle())
    }
}

extension ConversationComposer {
    func keyboardGrabberGestures<V: View>(_ bar: V) -> some View {
        bar
            .onTapGesture { dismissKeyboard() }
            .gesture(
                DragGesture(minimumDistance: 6)
                    .onEnded { if $0.translation.height > 8 { dismissKeyboard() } }
            )
            .accessibilityLabel("Fechar teclado")
            .accessibilityHint("Toque ou arraste para baixo para dispensar o teclado")
            .accessibilityAddTraits(.isButton)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var keyboardGrabber: some View {
        if focused.wrappedValue {
            keyboardGrabberGestures(keyboardGrabberBar)
        }
    }
}

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSeparator: some View {
        // Soft gold-breath hairline under live execution chrome.
        Rectangle().fill(AtlasTheme.accent.opacity(0.22)).frame(height: 1)
            .padding(.bottom, expanded ? 0 : 8)
            .accessibilityHidden(true)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSection: some View {
        if let live = liveBubble {
            ExecutingStrip(
                bubble: live,
                reduceMotion: reduceMotion,
                onStop: { model.cancel() },
                onSteer: live.traceId.map { trace in { steerTrace = ConversationSteerTraceRef(id: trace) } }
            )
                .padding(.top, expanded ? 0 : 4)
                .padding(.bottom, expanded ? 0 : 8)
                .transition(.opacity)
            liveExecutionSeparator
        }
    }
}

extension ConversationComposer {
    func submitSteer(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) {
        // Haptic lives on SteerInteractionSheet Enviar (medium) — avoid double fire.
        Task {
            await model.steerInteraction(traceId: traceId, instruction: instruction, scope: scope)
            if let receipt = steerReceipt(for: traceId) {
                model.toast = steerReceiptText(receipt)
            }
        }
    }
}

extension ConversationComposer {
    func steerReceipt(for traceId: TraceID) -> AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }

    func steerReceiptText(_ receipt: AtlasInteractionSteerResponse) -> String {
        receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"
    }
}


// Cycle 043 fuse → DraftStrip.swift

// Strip de anexos do composer — renderiza LocalDraft e nada mais

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if drafts.isEmpty {
            EmptyView()
        } else {
            draftThumbs
        }
    }
}

extension DraftStrip {
    var draftThumbLoop: some View {
        HStack(spacing: 12) {
            ForEach(drafts) { d in
                DraftThumb(draft: d, reduceMotion: reduceMotion,
                           onRemove: onRemove, onFailedTap: onFailedTap)
                    .transition(reduceMotion ? .opacity
                                : .scale(scale: 0.86).combined(with: .opacity))
            }
        }
        .padding(.top, 6).padding(.trailing, 6)
    }
}

extension DraftStrip {
    var draftThumbs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            draftThumbLoop
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
        // Contain without strip label: each DraftThumb keeps its own a11y node.
        .accessibilityElement(children: .contain)
        .animation(
            reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.82),
            value: drafts.map(\.id)
        )
    }
}


// Cycle 043 fuse → CameraPicker.swift

// zero lógica além de entregar os bytes; o AtlasImaging normaliza depois.
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    var onCaptureFailed: () -> Void = {}
    var onCancel: () -> Void = {}
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeUIViewController(context: Context) -> UIImagePickerController {
        makeCameraPicker(context: context)
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {
        applyReduceMotion(vc)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}

/// Cancelar = silêncio total (nunca toast de anexo); falha só quando bytes não saem.

enum CameraPickerA11y {
    static let spokenSurface = "Câmera para anexar foto"
    static let spokenHint = "Confirme a captura para anexar; cancelar não adiciona nada"
    static let captureFailedToast = "Não consegui capturar a foto"

    static let spokenChooseCamera = "Capturar foto na câmera"
    static let spokenChooseCameraHint = "Abre a câmera; nada é anexado até confirmar a captura"
}

extension CameraPicker.Coordinator {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.onCancel()
        parent.dismiss()
    }
}

extension CameraPicker {
    func makeCameraPicker(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        applyReduceMotion(picker)
        return picker
    }
}

extension CameraPicker {
    func applyReduceMotion(_ picker: UIImagePickerController) {
        if reduceMotion {
            picker.modalTransitionStyle = .crossDissolve
        }
    }
}

extension CameraPicker {
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.92) {
                parent.onCapture(data)
            } else {
                parent.onCaptureFailed()
            }
            parent.dismiss()
        }
    }
}


// Cycle 043 fuse → DraftThumb.swift

struct DraftThumb: View {
    let draft: LocalDraft
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbContent
            removeButton
        }
    }
}

/// Tamanho só quando bytes publicados; tipo imagem/arquivo honesto.

enum DraftThumbA11y {
    static func spokenRemove(_ draft: LocalDraft) -> String {
        DraftThumbA11yHints.spokenRemove(draft)
    }

    static let removeHint = DraftThumbA11yHints.removeHint
    static let failedHint = DraftThumbA11yHints.failedHint

    static func spokenFailedValue(_ message: String) -> String {
        DraftThumbA11yHints.spokenFailedValue(message)
    }
}

enum DraftThumbA11yHints {
    static let removeHint = "Remove este anexo antes do envio"
    static let failedHint = "Toque para ver o erro completo no aviso"

    static func spokenFailedValue(_ message: String) -> String {
        message.isEmpty ? "erro no envio" : message
    }

    static func spokenRemove(_ draft: LocalDraft) -> String {
        "remover anexo \(draft.fileName)"
    }
}

@MainActor
enum DraftThumbCache {
    static let store = NSCache<NSString, UIImage>()
    static func image(for draft: LocalDraft) -> UIImage? {
        if let hit = store.object(forKey: draft.id as NSString) { return hit }
        guard let data = draft.preview, let ui = UIImage(data: data) else { return nil }
        store.setObject(ui, forKey: draft.id as NSString); return ui
    }
}

extension DraftThumb {
    func removeButtonA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(DraftThumbA11y.spokenRemove(draft))
            .accessibilityHint(DraftThumbA11y.removeHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
            .accessibilityAddTraits(.isButton)
    }
}

extension DraftThumb {
    @ViewBuilder
    var removeButtonChrome: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(18)
            .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
            .frame(width: 48, height: 48)
            .contentShape(Circle())
    }
}

extension DraftThumb {
    @ViewBuilder var removeButton: some View {
        if draft.state != .subindo {
            removeButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onRemove(draft.id)
                } label: {
                    removeButtonChrome
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
            )
        }
    }
}

extension DraftThumb {
    @ViewBuilder var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(AtlasTheme.textPrimary) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AtlasTheme.bgRecessed.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.94)))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill").atlasSans(16)
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading).padding(6)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}

extension DraftThumb {
    var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }
}

extension DraftThumb {
    @ViewBuilder var thumb: some View {
        if draft.kind == .image, let ui = DraftThumbCache.image(for: draft) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill")
                    .atlasSans(20)
                    .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    // Soft gold-quiet file meta under doc glyph.
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(AtlasTheme.surfaceHi)
        }
    }
}

extension DraftThumbA11y {
    static func spokenThumbSizeParts(_ draft: LocalDraft) -> [String] {
        guard draft.bytes > 0 else { return [] }
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        return ["\(mb) megabytes"]
    }
}

extension DraftThumbA11y {
    static func spokenThumbReadyParts(_ draft: LocalDraft) -> [String]? {
        switch draft.state {
        case .pronto: return ["pronto para enviar"]
        case .subindo: return ["enviando"]
        default: return nil
        }
    }
}

extension DraftThumbA11y {
    static func spokenThumbStateParts(_ draft: LocalDraft) -> [String] {
        if let ready = spokenThumbReadyParts(draft) { return ready }
        if case .falhou(let message) = draft.state {
            var parts = ["falhou"]
            if !message.isEmpty { parts.append(message) }
            return parts
        }
        return []
    }
}

extension DraftThumbA11y {
    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        parts.append(contentsOf: spokenThumbSizeParts(draft))
        parts.append(contentsOf: spokenThumbStateParts(draft))
        return parts.joined(separator: ", ")
    }
}

extension DraftThumb {
    func thumbContentA11y<V: View>(_ framed: V) -> some View {
        framed
            .overlay { stateVeil }
            .onTapGesture {
                if let m = failedMessage {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onFailedTap("falhou: \(m)")
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DraftThumbA11y.spokenThumb(draft))
            .accessibilityValue(failedMessage.map { DraftThumbA11y.spokenFailedValue($0) } ?? "")
            .atlasAccessibilityHint(failedMessage != nil ? DraftThumbA11y.failedHint : nil)
            .accessibilityAddTraits(failedMessage != nil ? .isButton : [])
            .modifier(DraftThumbFailedA11yAction(
                failedMessage: failedMessage,
                reduceMotion: reduceMotion,
                onFailedTap: onFailedTap
            ))
            .accessibilityIdentifier(A11yID.draft(draft.id))
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: draft.state)
    }
}

/// VO activate for failed draft (mirrors onTapGesture retry path).
private struct DraftThumbFailedA11yAction: ViewModifier {
    let failedMessage: String?
    let reduceMotion: Bool
    let onFailedTap: (String) -> Void

    func body(content: Content) -> some View {
        if let m = failedMessage {
            content.accessibilityAction(named: "Ver falha do anexo") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onFailedTap("falhou: \(m)")
            }
        } else {
            content
        }
    }
}

extension DraftThumb {
    var thumbFrame: some View {
        thumb
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .stroke(
                        failedMessage != nil
                            ? AtlasTheme.domOperacional.opacity(0.8)
                            : AtlasTheme.separator,
                        lineWidth: failedMessage != nil ? 1.5 : 1
                    )
            )
            .atlasElevation(radius: 6, y: 2, opacity: 0.14)
    }
}

extension DraftThumb {
    var thumbContent: some View {
        thumbContentA11y(thumbFrame)
    }
}


// Cycle 044 fuse → ComposerToolbar.swift

// Toolbar do composer: paperclip + campo + trailing (enviar / processando / menu

struct ComposerToolbar: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding
    var expanded: Bool
    var mode: String
    var liveBubble: ChatBubble?
    var onAttach: () -> Void
    var onShowWorkspace: () -> Void
    var onShowMode: () -> Void
    var onShowEffort: () -> Void
    var onSend: () -> Void

    var body: some View {
        toolbarRow
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowAttach: some View {
        attachButton
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowField: some View {
        composerTextField
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowTrailing: some View {
        trailingControl
    }
}

extension ComposerToolbar {
    var toolbarRow: some View {
        HStack(spacing: 10) {
            toolbarRowAttach
            toolbarRowField
            toolbarRowTrailing
        }
        .accessibilityElement(children: .contain)
    }
}

extension ComposerToolbar {
    var canSubmitFromDraft: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || !model.drafts.isEmpty
    }
}

extension ComposerToolbar {
    var canSubmitWhileSending: Bool {
        !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension ComposerToolbar {
    var canSubmit: Bool {
        if model.isSending || liveBubble != nil {
            return canSubmitWhileSending
        }
        return canSubmitFromDraft
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var composerFieldPlaceholder: some View {
        Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
            // Soft gold-quiet composer placeholder invite.
            .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.accent.opacity(0.48))
            .allowsHitTesting(false).opacity(model.draftText.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.considered), value: model.draftText.isEmpty)
            .accessibilityHidden(true)
    }
}

extension ComposerToolbar {
    var composerTextFieldInput: some View {
        TextField("", text: Binding(
            get: { model.draftText },
            set: { model.updateDraft($0) }
        ), axis: .vertical)
            .font(AtlasFont.serif(15)).foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent).lineLimit(1...6).focused(focused)
            .accessibilityIdentifier(A11yID.conversationInput)
            .accessibilityLabel(spokenInputLabel())
            .accessibilityHint(spokenInputHint())
    }
}

extension ComposerToolbar {
    var composerTextField: some View {
        ZStack(alignment: .topLeading) {
            composerFieldPlaceholder
            composerTextFieldInput
        }
    }
}

extension ComposerToolbar {
    var attachButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAttach()
        } label: {
            Image(systemName: "paperclip")
                .atlasSans(17, .medium)
                // Soft gold-quiet secondary chrome — match conversation ellipsis family.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .frame(width: 48, height: 48)
                .background(Circle().fill(AtlasTheme.surfaceHi.opacity(0.55)))
                .atlasElevation(radius: 4, y: 1, opacity: 0.1)
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("Adicionar anexo")
        .accessibilityHint("Abre foto, arquivo ou colar")
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    var isExecuting: Bool { model.isSending || liveBubble != nil }

    func spokenSendLabel(canSubmit: Bool) -> String {
        if canSubmit {
            return isExecuting ? "Adicionar à fila" : "Enviar ao Atlas"
        }
        return isExecuting
            ? "Enviar indisponível, Atlas processando"
            : "Enviar indisponível, sem mensagem nem anexo"
    }
}

extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        canSubmit ? spokenSendHintReady() : spokenSendHintBlocked()
    }
}

extension ComposerToolbar {
    func spokenEffortLightLabel(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "Esforço automático, Atlas Decide escolhe"
        case .fast: return "Esforço rápido"
        case .balanced: return "Esforço normal"
        default: return nil
        }
    }
}

extension ComposerToolbar {
    func spokenEffortLabel(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLightLabel(effort) { return light }
        switch effort {
        case .deep: return "Esforço profundo"
        case .max: return "Esforço máximo"
        default: return "Esforço automático, Atlas Decide escolhe"
        }
    }
}

extension ComposerToolbar {
    func spokenEffortHint() -> String {
        "Abre opções de esforço computacional para o próximo envio"
    }

    func spokenOptionsHint() -> String {
        "Modo, esforço e workspace; \(spokenSendHint(canSubmit: false))"
    }
}

extension ComposerToolbar {
    func spokenInputLabel() -> String {
        model.bubbles.isEmpty ? "Mensagem para o Atlas" : "Continuar conversa com o Atlas"
    }

    func spokenInputHint() -> String {
        if canSubmit {
            return isExecuting ? "Texto para a fila do próximo turno" : "Texto do próximo envio"
        }
        return "Escreva aqui para habilitar o envio"
    }
}

extension ComposerToolbar {
    func spokenProcessingLabel() -> String { "Atlas processando" }
}

extension ComposerToolbar {
    func spokenSendHintBlocked() -> String {
        if isExecuting {
            return "Escreva uma mensagem para adicionar à fila durante a execução"
        }
        if !model.drafts.isEmpty {
            return "Adicione texto ou envie os anexos prontos"
        }
        return "Escreva uma mensagem ou adicione um anexo para enviar"
    }
}

extension ComposerToolbar {
    func spokenSendHintReady() -> String {
        isExecuting
            ? "Envia esta mensagem na fila do próximo turno"
            : "Envia mensagem e anexos ao Atlas"
    }
}

extension AttachmentStrip {
    @ViewBuilder
    var attachmentDraftBranch: some View {
        if !drafts.isEmpty {
            DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                       onRemove: onRemove, onFailedTap: onFailedTap)
        }
    }
}

struct AttachmentStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let uploadPercent: Double?
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if isVisible {
            Group {
                attachmentDraftBranch
                uploadProgressRow
            }
            .accessibilityIdentifier(A11yID.composerAttachmentStrip)
        }
    }
}

extension AttachmentStrip {
    func uploadPercentLabel(_ p: Double) -> some View {
        Text("\(Int(p * 100))%")
            // Soft gold-quiet upload progress meta.
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent.opacity(0.7))
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressBar(_ p: Double) -> some View {
        ProgressView(value: p).tint(AtlasTheme.accent)
    }
}

extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            uploadProgressStack(p)
        }
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressA11y<Content: View>(_ content: Content, percent: Double) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Enviando anexos, \(Int(percent * 100)) por cento")
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressRow(_ p: Double) -> some View {
        HStack(spacing: 10) {
            uploadProgressBar(p)
            uploadPercentLabel(p)
        }
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressStack(_ p: Double) -> some View {
        uploadProgressA11y(uploadProgressRow(p), percent: p)
    }
}

extension AttachmentStrip {
    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}

extension ComposerToolbar {
    @ViewBuilder var trailingOptionsMenu: some View {
        Menu {
            optionsMenuButtons
        } label: {
            Image(systemName: "ellipsis")
                .atlasSans(17, .semibold)
                // Soft gold-quiet secondary chrome — match attach + header ellipsis.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .frame(width: 48, height: 48)
                // Match attach soft circle — secondary composer chrome plane.
                .background(Circle().fill(AtlasTheme.surfaceHi.opacity(0.55)))
                .atlasElevation(radius: 4, y: 1, opacity: 0.1)
                .contentShape(Circle())
        }
        .accessibilityLabel("Opções da conversa")
        .accessibilityHint(spokenOptionsHint())
        .accessibilityIdentifier(A11yID.conversationOptions)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var optionsMenuButtons: some View {
        optionsWorkspaceButton
        optionsModeButton
        optionsEffortButton
    }
}

extension ComposerToolbar {
    var optionsEffortButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowEffort()
        } label: {
            Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
        }
        .accessibilityLabel(spokenEffortLabel(model.effort))
        .accessibilityHint(spokenEffortHint())
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    var optionsModeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowMode()
        } label: {
            Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
        }
        .accessibilityLabel("Modo, \(mode)")
        .accessibilityHint("Abre opções de modo para o próximo envio")
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    var optionsWorkspaceButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowWorkspace()
        } label: {
            Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
        }
        .accessibilityLabel("Workspace, \(model.workspaceName ?? "Atlas")")
        .accessibilityHint("Abre o seletor de workspace da conversa")
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var trailingControlBranch: some View {
        if canSubmit {
            trailingSendButton
        } else if isExecuting {
            trailingProcessing
        } else {
            trailingOptionsMenu
        }
    }
}

extension ComposerToolbar {
    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder var trailingControl: some View {
        trailingControlBranch
    }
}

extension ComposerToolbar {
    var trailingProcessing: some View {
        ZStack {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(29)
                // Soft gold-quiet ghost send — honest disabled, still on brand.
                .foregroundStyle(AtlasTheme.accent.opacity(0.28))
                .accessibilityHidden(true)
        }
        .frame(width: 48, height: 48)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(spokenProcessingLabel()), \(spokenSendLabel(canSubmit: false))")
        .accessibilityHint(spokenSendHint(canSubmit: false))
        .accessibilityAddTraits(reduceMotion ? [] : .updatesFrequently)
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}

extension ComposerToolbar {
    var trailingSendButton: some View {
        Button {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onSend()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(30)
                .foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.35), radius: 6, y: 1)
                .frame(width: 48, height: 48)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityLabel(spokenSendLabel(canSubmit: true))
        .accessibilityHint(spokenSendHint(canSubmit: true))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(10) // primary commit surfaces first in VO
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}


// Cycle 044 fuse → ConversationMessages.swift

// Scroll chrome: ConversationMessages+Scroll.swift
// Empty + bubbles: ConversationMessages+List.swift

struct ConversationMessages: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var emptyPrompt: String?
    var emptySuggestions: [String]?
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

extension ConversationMessages {
    @ViewBuilder
    func emptyMessages() -> some View {
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
            emptyConversationBody
        }
    }
}

extension ConversationMessages {
    @ViewBuilder
    var emptyConversationBody: some View {
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
            // Contain without fused label: each turn keeps its own a11y node.
            .accessibilityElement(children: .contain)
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

enum ConversationMessagesA11y {
    static let scrollFABLabel = ConversationMessagesA11yFAB.scrollFABLabel
    static let scrollFABHint = ConversationMessagesA11yFAB.scrollFABHint

    static func spokenChangeReview(patchCount: Int) -> String {
        ConversationMessagesA11yReview.spokenChangeReview(patchCount: patchCount)
    }

    static let changeReviewHint = ConversationMessagesA11yReview.changeReviewHint
}

enum ConversationMessagesA11yFAB {
    static let scrollFABLabel = "Ir para o fim da conversa"
    static let scrollFABHint = "Volta às mensagens mais recentes"
}

enum ConversationMessagesA11yReview {
    static func spokenChangeReview(patchCount: Int) -> String {
        if patchCount > 0 {
            let noun = patchCount == 1 ? "patch" : "patches"
            return "revisar mudanças, \(patchCount) \(noun)"
        }
        return "revisar mudanças desta execução"
    }

    static let changeReviewHint = "Abre arquivos, diff e provas desta execução"
}

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChipButton(for bubble: ChatBubble, trace: TraceID) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            reviewTrace = ConversationReviewTraceRef(id: trace)
        } label: {
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
        .accessibilityAddTraits(.isButton)
    }
}

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

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if showsChangeReviewChip(for: bubble), let trace = bubble.traceId {
            changeReviewChipButton(for: bubble, trace: trace)
        }
    }
}

extension ConversationMessages {
    var changeReviewChipLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.forwardslash.minus").atlasSans(11)
            Text("Revisar mudanças").font(AtlasFont.serif(13, .medium))
        }
        // Soft gold-quiet invite chip — same family as secondary chrome.
        .foregroundStyle(AtlasTheme.accent.opacity(0.78))
        .padding(.horizontal, 13).padding(.vertical, 7)
        .frame(minHeight: 48)
        .background(
            Capsule().fill(AtlasTheme.surface.opacity(0.55))
                .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.45), lineWidth: 1))
        )
        .atlasElevation(radius: 6, y: 2, opacity: 0.1)
        .contentShape(Capsule())
    }
}

extension ConversationMessages {
    func scrollBubbleEmptyChange(_ empty: Bool) {
        if empty { awayFromBottom = false }
    }
}

extension ConversationMessages {
    func scrollBubbleListChange(proxy: ScrollViewProxy) {
        autoScrollToBottom(proxy: proxy)
    }
}

extension ConversationMessages {
    @ViewBuilder
    func scrollChrome<Content: View>(proxy: ScrollViewProxy, @ViewBuilder content: () -> Content) -> some View {
        scrollPreferenceChrome(proxy: proxy, content: content)
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: showsScrollFAB)
            .onChange(of: model.bubbles.isEmpty) { _, empty in
                scrollBubbleEmptyChange(empty)
            }
            .onChange(of: model.bubbles) {
                scrollBubbleListChange(proxy: proxy)
            }
    }
}

extension ConversationMessages {
    var showsScrollFAB: Bool { awayFromBottom && !model.bubbles.isEmpty }
}

extension ConversationMessages {
    func autoScrollToBottom(proxy: ScrollViewProxy) {
        guard !model.bubbles.isEmpty else { return }
        let count = model.bubbles.count
        let now = CFAbsoluteTimeGetCurrent()
        guard shouldAutoScroll(now: now, count: count) else { return }
        lastScrollAt = now
        lastScrollBubbleCount = count
        withAnimation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}

extension ConversationMessages {
    func shouldAutoScroll(now: CFAbsoluteTime, count: Int) -> Bool {
        let countChanged = count != lastScrollBubbleCount
        return countChanged || now - lastScrollAt >= 0.1
    }
}

extension ConversationMessages {
    func applyScrollDistancePref<Content: View>(_ content: Content) -> some View {
        content.onPreferenceChange(BottomDistanceKey.self) { minY in
            guard !model.bubbles.isEmpty else {
                awayFromBottom = false
                return
            }
            awayFromBottom = minY > UIScreen.main.bounds.height + 140
        }
    }
}

extension ConversationMessages {
    func scrollFABAction(proxy: ScrollViewProxy) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.considered)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}

extension ConversationMessages {
    @ViewBuilder
    func scrollFABButton(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollFABAction(proxy: proxy)
        } label: {
            scrollFABLabel
        }
    }
}

extension ConversationMessages {
    @ViewBuilder
    func scrollFAB(proxy: ScrollViewProxy) -> some View {
        if showsScrollFAB {
            scrollFABChrome(scrollFABButton(proxy: proxy))
        }
    }
}

extension ConversationMessages {
    func scrollFABChrome<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(PressableScale())
            .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
            .transition(reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity))
            .accessibilityLabel(ConversationMessagesA11y.scrollFABLabel)
            .accessibilityHint(ConversationMessagesA11y.scrollFABHint)
            .accessibilityIdentifier(A11yID.conversationScrollFAB)
            .accessibilityAddTraits(.isButton)
    }
}

extension ConversationMessages {
    var scrollFABLabel: some View {
        Image(systemName: "arrow.down")
            .atlasSans(15, .semibold)
            .foregroundStyle(AtlasTheme.textPrimary)
            .frame(width: 48, height: 48)
            .background(Circle().fill(AtlasTheme.surfaceHi)
                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                .atlasElevation(radius: 8, y: 2, opacity: 0.25))
            .contentShape(Circle())
    }
}

struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

extension ConversationMessages {
    @ViewBuilder
    func scrollContentIndicators<Content: View>(_ content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
    }
}

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


// Cycle 044 fuse → EditorialTurn.swift

// Turno editorial — extraído de ConversationChrome (CICLO B compressão).

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

    var body: some View {
        applyArrival(turnBody)
    }
}

struct FeedbackRow: View {
    let active: String?
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                feedbackChip(kind)
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}

extension FeedbackRow {
    func feedbackChipA11y<Content: View>(
        _ content: Content,
        kind: FeedbackKind,
        isActive: Bool
    ) -> some View {
        content
            .accessibilityLabel(EditorialTurnA11y.spokenFeedbackLabel(kind: kind, active: isActive))
            .accessibilityHint(EditorialTurnA11y.spokenFeedbackHint())
            .accessibilityAddTraits(isActive ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier(A11yID.editorialTurnFeedback(kind.rawValue))
    }
}

extension FeedbackRow {
    func feedbackChipLabel(_ kind: FeedbackKind, isActive: Bool) -> some View {
        Text(isActive ? "\(kind.label) ✓" : kind.label)
            .font(AtlasFont.serifItalic(13))
            // Soft gold-quiet inactive feedback; active stays moss.
            .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.accent.opacity(0.55))
            .padding(.horizontal, 12).padding(.vertical, 6)
            .frame(minHeight: 48)
            .contentShape(Capsule())
            .background(
                Capsule().fill(isActive ? AtlasTheme.domAutonomos.opacity(0.08) : AtlasTheme.surface.opacity(0.4))
                    .overlay(
                        Capsule().stroke(
                            isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.goldBorder.opacity(0.4),
                            lineWidth: 1
                        )
                    )
            )
            .atlasElevation(radius: 4, y: 1, opacity: isActive ? 0.12 : 0.06)
    }
}

extension FeedbackRow {
    func feedbackChip(_ kind: FeedbackKind) -> some View {
        let isActive = active == kind.activeAction
        return feedbackChipA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onFeedback(kind)
            } label: {
                feedbackChipLabel(kind, isActive: isActive)
            }
            .buttonStyle(PressableScale()),
            kind: kind,
            isActive: isActive
        )
    }
}

func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "" }
    let x = p.lowercased()
    for (k, v) in [("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
                   ("hermes", "hermes"), ("minimax", "minimax"),
                   ("council", "conselho"), ("conselho", "conselho")] where x.contains(k) {
        return v
    }
    return x
}

struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    let reduceMotion: Bool
    @State var shown = false

    var body: some View {
        Text(signature)
            // Soft gold-quiet editorial signature.
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent.opacity(0.58))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .accessibilityLabel(EditorialTurnA11y.spokenSignature(provider: provider, model: model, elapsedMs: elapsedMs))
            .accessibilityIdentifier(A11yID.editorialTurnSignature)
            .onAppear { revealSignature() }
    }
}

extension SignatureLine {
    /// Modelo ou provider reais — nunca fabrica «atlas» quando o contrato não publica quem respondeu.
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        let hasModel = model.map { !$0.isEmpty && !$0.hasSuffix("_default") } ?? false
        let hasProvider = provider.map { !$0.isEmpty } ?? false
        return hasModel || hasProvider
    }
}

extension SignatureLine {
    var signature: String {
        let who = signatureWho
        if let ms = elapsedMs, ms > 0 { return "— \(who), em \(humanDuration(ms))" }
        return "— \(who)"
    }

    var signatureWho: String {
        if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
        let word = providerWord(provider)
        return word.isEmpty ? "provedor não publicado" : word
    }
}

extension SignatureLine {
    func revealSignature() {
        if reduceMotion { shown = true; return }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.easeIn(duration: AtlasMotion.considered)) { shown = true }
        }
    }
}

extension EditorialTurnA11y {
  static func spokenSignature(provider: String?, model: String?, elapsedMs: Int?) -> String {
    guard let who = signatureWho(provider: provider, model: model) else { return "" }
    if let ms = elapsedMs, ms > 0 { return "resposta de \(who), em \(humanDuration(ms))" }
    return "resposta de \(who)"
  }
}

extension EditorialTurnA11y {
  static func spokenUserMessage(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
  }

  static let spokenFinalAnswerKicker = "Resposta final"

  static let copyLongPressHint = "Pressionar e segurar copia a resposta"
}

enum EditorialTurnA11y {}

extension EditorialTurnA11y {
  static func spokenFeedbackBase(kind: FeedbackKind) -> String {
    switch kind {
    case .util: return "marcar resposta como útil"
    case .contexto: return "marcar contexto errado"
    case .longo: return "marcar resposta longa demais"
    case .fraco: return "marcar resposta fraca"
    }
  }
}

extension EditorialTurnA11y {
  static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
    let base = spokenFeedbackBase(kind: kind)
    return active ? "\(base), selecionado" : base
  }

  static func spokenFeedbackHint() -> String {
    "envia feedback ao roteamento do Atlas para este turno"
  }
}

extension EditorialTurnA11y {
  static func signatureWho(provider: String?, model: String?) -> String? {
    if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
    if let provider, !provider.isEmpty {
      let word = providerWord(provider)
      return word.isEmpty ? provider : word
    }
    return nil
  }
}

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
        .accessibilityHint(EditorialTurnA11y.copyLongPressHint)
        .accessibilityAction(named: "Copiar resposta") { onCopy() }
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
        if bubble.streaming, bubble.hasLiveExecutionSurface {
            ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
        }
    }
}

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

extension EditorialTurn {
    @ViewBuilder
    var assistantClosing: some View {
        if !bubble.streaming,
           ExecutionProof.shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            ExecutionProof(bubble: bubble, artifactItems: artifactItems, onOpenArtifacts: onOpenArtifacts)
            Text("Resposta final")
                .font(AtlasFont.mono(9, .semibold)).tracking(0.4)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityLabel(EditorialTurnA11y.spokenFinalAnswerKicker)
                .accessibilityAddTraits(.isHeader)
        }
        assistantClosingTail
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingMeta: some View {
        if !bubble.streaming {
            if SignatureLine.shouldDisplay(provider: bubble.provider, model: bubble.model) {
                SignatureLine(
                    provider: bubble.provider, model: bubble.model,
                    elapsedMs: bubble.elapsedMs, reduceMotion: reduceMotion)
            }
            FeedbackRow(active: bubble.feedbackAction, reduceMotion: reduceMotion, onFeedback: onFeedback)
        }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingTail: some View {
        if !bubble.text.isEmpty {
            AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
        }
        assistantClosingMeta
    }
}

extension EditorialTurn {
    // F2.10: igualdade só no que a tela mostra — closures recriadas pelo pai
    // não invalidam o subtree (pare com `.equatable()` no call site).
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }
}

extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            userQuote
            userEditResendButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension EditorialTurn {
    var userEditResendButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onEditResend()
        } label: {
            userEditResendLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("Editar esta mensagem e reenviar como novo turno")
        .accessibilityHint("Abre o compositor com este texto para um novo envio")
        .accessibilityAddTraits(.isButton)
    }
}

extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            // Ação fala em sans (mono é hash/recibo/meta — canon §C);
            // gold-quiet affordance de ação sem gritar.
            Text("Editar e reenviar")
                .atlasSans(11, .medium)
        }
        .foregroundStyle(AtlasTheme.accent.opacity(0.78))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .frame(minHeight: 48, alignment: .leading)
        .contentShape(Rectangle())
        .background(
            Capsule().fill(AtlasTheme.surface.opacity(0.5))
                .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.45), lineWidth: 1))
        )
        .atlasElevation(radius: 6, y: 2, opacity: 0.1)
    }
}

extension EditorialTurn {
    var userQuote: some View {
        Text("\"\(bubble.text)\"")
            .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.leading, 16)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel(EditorialTurnA11y.spokenUserMessage(bubble.text))
    }
}


// Cycle 044 fuse → ConversationCockpit.swift

// O cockpit da execução — faixa no composer, ribbon, narrativa viva e a

extension ExecutingStrip {
    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            stripStatusMeta
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
        // Live elapsed/activity copy moves; Reduce Motion keeps it static.
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
            stripStatusActivityRow(act)
        } else {
            stripStatusIdleLine
        }
    }
}

extension ExecutingStrip {
    var stripStatusIdleLine: some View {
        Text("Seguindo a execução")
            .font(AtlasFont.serif(13))
            .foregroundStyle(AtlasTheme.accent.opacity(0.85))
            .lineLimit(1)
            .layoutPriority(2)
            .accessibilityHidden(true)
    }
}

extension ExecutingStrip {
    @ViewBuilder
    func stripStatusActivityRow(_ act: AtlasAgentActivity) -> some View {
        HStack(spacing: 5) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
            Text(act.title)
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusLeading: some View {
        if bubble.showsReconnectSurface {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.accent.opacity(0.9))
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusDiffStats: some View {
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusEventTimer: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusMeta: some View {
        stripStatusEventTimer
        stripStatusDiffStats
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusProgressLine: some View {
        if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectLine: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectOrProgress: some View {
        if bubble.showsReconnectSurface, bubble.reconnectPrimaryLine != nil {
            stripStatusReconnectLine
        } else if bubble.executionProgress != nil {
            stripStatusProgressLine
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface || bubble.executionProgress != nil {
            stripStatusReconnectOrProgress
        } else {
            stripStatusActivityOrIdle
        }
    }
}

struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var reduceMotion = false
    /// Quando o container pai compõe o spoken (reconexão, watchdog), o banner fica só visual.
    var embedInParent = false
    var accessibilityIdentifier: String?

    var body: some View {
        bannerChrome
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(embedInParent)
            .accessibilityLabel(text)
            .atlasAccessibilityIdentifier(accessibilityIdentifier)
    }
}

extension ExecutionBanner {
    func bannerChromeFrame<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(tint.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(tint.opacity(0.35), lineWidth: 1))
            .atlasElevation(radius: 6, y: 2, opacity: 0.1)
    }
}

extension ExecutionBanner {
    var bannerContentRow: some View {
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
    }
}

extension ExecutionBanner {
    var bannerChrome: some View {
        bannerChromeFrame(bannerContentRow)
    }
}

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        executionRibbonCard(executionRibbonStack)
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("Atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .padding(.leading, 24)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanes: some View {
        if !bubble.agents.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                agentLanesCaption
                ForEach(bubble.agents) { AgentRow(agent: $0, compactLane: bubble.agents.count >= 2) }
            }.padding(.leading, 24)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanesCaption: some View {
        if bubble.agents.count >= 2 {
            Text("Lanes")
                .font(AtlasFont.mono(10, .medium))
                .tracking(0.3)
                .foregroundStyle(AtlasTheme.accent.opacity(0.75))
                .accessibilityAddTraits(.isHeader)
        }
    }
}


extension ExecutionRibbon {
    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var reconnectBannerStack: some View {
        ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
    }
}

extension ExecutionRibbon {
    func executionRibbonCard<V: View>(_ content: V) -> some View {
        content
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            // Match plan-card plane — live ribbon floats above the turn stream.
            .atlasElevation(radius: 8, y: 2, opacity: 0.12)
    }
}

extension ExecutionRibbon {
    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            activitiesTimelineBlock
            agentLanes
            decideStrategyLine
        }
    }
}

extension AgentRow {
    var agentRowContent: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
                // Soft live bloom when the agent is actively processing.
                .shadow(
                    color: statusColor.opacity(statusColorActive != nil ? 0.45 : 0.12),
                    radius: statusColorActive != nil ? 3 : 1,
                    y: 0
                )
            Text(agent.agent ?? providerWord(agent.provider))
                // Soft gold-quiet agent name mono.
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent.opacity(0.72))
            agentModelLabel
            Spacer()
            // Soft gold-quiet status word.
            Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
        }
    }
}

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

extension AgentRow {
    func agentRowChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.vertical, compactLane ? 3 : 0)
            .padding(.horizontal, compactLane ? 8 : 0)
            .background {
                if compactLane {
                    Capsule().fill(AtlasTheme.bgRecessed)
                        // Soft gold-quiet agent compact lane chrome.
                        .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
                }
            }
            .atlasElevation(radius: 4, y: 1, opacity: compactLane ? 0.08 : 0)
    }
}

extension AgentRow {
    @ViewBuilder
    var agentModelLabel: some View {
        if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
            // Soft gold-quiet model meta.
            Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent.opacity(0.55)).lineLimit(1)
        }
    }
}

extension AgentRow {
    var statusColorActive: Color? {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        default: return nil
        }
    }
}

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        if let active = statusColorActive { return active }
        switch turnStatus {
        case .failed, .cancelled: return AtlasTheme.domOperacional
        // Soft gold-quiet idle agent status dot.
        default: return AtlasTheme.accent.opacity(0.42)
        }
    }
}

extension AgentRow {
    var statusWordQueued: String? {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordActive: String? {
        if let queued = statusWordQueued { return queued }
        switch turnStatus {
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordDone: String? {
        switch turnStatus {
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordTerminal: String {
        if let done = statusWordDone { return done }
        if case .unknown(let raw) = turnStatus { return raw }
        return statusWordActive ?? "—"
    }
}

extension AgentRow {
    var statusWord: String {
        statusWordActive ?? statusWordTerminal
    }
}

extension ChatBubble {
    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }
}

extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }
}

extension ChatBubble {
    var reconnectBannerIcon: String {
        executionPresentationState?.kind == .recovering
            ? "arrow.triangle.2.circlepath"
            : "wifi.exclamationmark"
    }
}

extension ChatBubble {
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
}

extension ChatBubble {
    var reconnectActiveTimerMs: Int? {
        guard streaming,
              executionPresentationState?.kind == .recovering,
              let timer = executionPresentationState?.timer
        else { return nil }
        return timer.elapsedActiveMilliseconds
    }
}

extension ChatBubble {
    var reconnectSpokenCoreParts: [String] {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        return parts
    }
}

extension ChatBubble {
    var reconnectSpokenLabel: String {
        var parts = reconnectSpokenCoreParts
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}

// Banner de reconexão — só `reconnectNotice` (transporte) e

struct ReconnectBanner: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        if bubble.showsReconnectSurface, let primary = bubble.reconnectPrimaryLine {
            reconnectBannerBody(primary: primary)
        }
    }
}

extension ReconnectBanner {
    @ViewBuilder
    func reconnectBannerBody(primary: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ExecutionBanner(
                text: primary,
                icon: bubble.reconnectBannerIcon,
                tint: AtlasTheme.textSecondary,
                reduceMotion: reduceMotion,
                embedInParent: true
            )
            secondaryLines
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bubble.reconnectSpokenLabel)
        .accessibilityIdentifier(A11yID.executionReconnectBanner)
    }
}

extension ReconnectBanner {
    @ViewBuilder
    var reconnectActiveTimerLine: some View {
        if let ms = bubble.reconnectActiveTimerMs {
            Text("Ativo \(ExecutionStateCard.clock(ms))")
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(AtlasTheme.accent.opacity(0.78))
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}

extension ReconnectBanner {
    @ViewBuilder
    var reconnectSecondaryLoop: some View {
        ForEach(Array(bubble.reconnectSecondaryLines.enumerated()), id: \.offset) { _, line in
            Text(line)
                .font(AtlasFont.mono(10))
                // Soft gold-quiet reconnect secondary meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.58))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension ReconnectBanner {
    @ViewBuilder
    var secondaryLines: some View {
        reconnectSecondaryLoop
        reconnectActiveTimerLine
    }
}

/// Só fala quando o stream publica streaming e o contador é real.

enum SilenceWatchdogA11y {
    static func spoken(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }
}

extension SilenceWatchdog {
    @ViewBuilder
    func silenceGate(now: Date) -> some View {
        if bubble.streaming,
           let silence = silenceSeconds(now: now),
           silence > 90 {
            silenceBanner(seconds: silence)
        }
    }
}

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            silenceGate(now: context.date)
        }
    }
}

extension SilenceWatchdog {
    func silenceBanner(seconds: Int) -> some View {
        Group {
            ExecutionBanner(
                text: "Sem novos eventos há \(seconds)s",
                icon: "timer",
                tint: AtlasTheme.domOperacional,
                reduceMotion: reduceMotion,
                embedInParent: true
            )
            .modifier(NumericTextTransition(enabled: !reduceMotion))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SilenceWatchdogA11y.spoken(seconds: seconds))
        .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
    }
}

extension SilenceWatchdog {
    func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}


// Cycle 044 fuse → PlanCard.swift

// O PLANO da obra — o roteiro que o servidor computou (workflow, passos,
// ferramentas, agentes, gates). Antes ficava invisível; agora cada passo
// mostra done/atual/pendente a partir do checkpoint REAL (executionProgress).
// Sem plano no trace, o card não existe. Nada é inventado.

struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var showDetail = false
    @State var showRevisions = false

    var body: some View {
        planCardGate
    }

    // MARK: Progress / plan data

    var plan: AtlasExecutionPlan? { bubble.executionPlan }
    /// Checkpoint observado no stream; nil = nenhum passo marcado ainda (tudo pendente).
    var executionProgress: AtlasExecutionPlan.Progress? { bubble.executionProgress }
    var currentIndex: Int? { executionProgress?.current }
    var isTerminal: Bool { executionProgress?.isTerminal == true }

    var revisions: [AtlasTraceGovernance.PlanRevision] { bubble.planRevisions }
    /// Só revisões com metadata real do servidor — ausência não vira “v1” nem motivo genérico.
    var meaningfulRevisions: [AtlasTraceGovernance.PlanRevision] {
        revisions.filter { rev in
            rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
        }
    }

    // MARK: Gate + chrome + body

    @ViewBuilder
    var planCardGate: some View {
        if let plan, !plan.steps.isEmpty {
            planCardChrome(plan: plan) {
                planCardBodyStack(plan: plan)
            }
        }
    }

    func planCardChrome<Content: View>(plan: AtlasExecutionPlan, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            .atlasElevation(radius: 8, y: 2, opacity: 0.12)
            // Contain without fused label: detail/revisions toggles stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.planCard)
    }

    @ViewBuilder
    func planCardBodyStack(plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            planBody(plan: plan)
        }
    }

    @ViewBuilder
    func planBody(plan: AtlasExecutionPlan) -> some View {
        planHeader(plan: plan)
        planStepsList(plan: plan)
        if session.auditModeEnabled, isTerminal, let progress = executionProgress {
            auditTerminalLine(plan: plan, progress: progress)
        }
        // C19 / cena 02: "comparar versões" só com planRevisions reais.
        if !meaningfulRevisions.isEmpty {
            revisionToggle(plan: plan)
        }
        planDetailSection(plan: plan)
    }

    // MARK: Header

    func planHeader(plan: AtlasExecutionPlan) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "list.bullet.rectangle")
                .atlasSans(12).foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
            Text(plan.title)
                .font(AtlasFont.serif(13, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(plan.title)
            Spacer(minLength: 0)
            if let progress = bubble.executionProgress {
                planHeaderProgress(progress)
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    func planHeaderProgress(_ progress: AtlasExecutionPlan.Progress) -> some View {
        Text("\(progress.current)/\(progress.total)")
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityLabel(spokenProgressBadge(progress))
            .accessibilityIdentifier(A11yID.planProgress)
    }

    // MARK: Steps

    enum StepState { case done, current, pending }

    func planStepsList(plan: AtlasExecutionPlan) -> some View {
        planStepsRows(plan: plan)
            .accessibilityIdentifier(A11yID.planSteps)
    }

    func planStepsRows(plan: AtlasExecutionPlan) -> some View {
        let total = plan.steps.count
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(plan.steps.enumerated()), id: \.element.id) { idx, step in
                planStepRow(step: step, index: idx, total: total)
            }
        }
    }

    func planStepRow(step: AtlasExecutionPlan.Step, index: Int, total: Int) -> some View {
        let state = stepState(index)
        return PlanStepRowView(
            step: step,
            index: index,
            total: total,
            state: state,
            isLast: index == total - 1,
            spokenLabel: spokenStep(step: step, state: state, index: index, total: total),
            reduceMotion: reduceMotion
        )
    }

    func stepState(_ idx: Int) -> StepState {
        guard let c = currentIndex else { return .pending }
        if isTerminal { return .done }
        if idx + 1 < c { return .done }
        if idx + 1 == c { return .current }
        return .pending
    }
}

// A11y e spoken labels do PlanCard.

extension PlanCard {
    func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: StepState,
        index: Int,
        total: Int
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", step.title]
        parts.append(Self.spokenStepState(state))
        return parts.joined(separator: ", ")
    }

    static func spokenStepState(_ state: StepState) -> String {
        switch state {
        case .done: "concluído"
        case .current: "em curso"
        case .pending: "pendente"
        }
    }

    func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }

    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    func spokenAuditTerminal(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress) -> String {
        "auditoria do plano, \(plan.steps.count) passos planejados, \(min(progress.current, progress.total)) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }

    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}

// Auditoria terminal do plano (modo audit).

extension PlanCard {
    func auditTerminalLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        auditTerminalCopy(plan: plan, progress: progress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenAuditTerminal(plan: plan, progress: progress))
            .accessibilityAddTraits(.isStaticText)
    }

    func auditTerminalCopy(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        HStack(spacing: 6) {
            auditCaption
            auditProgressLine(plan: plan, progress: progress)
            Spacer(minLength: 0)
            auditStatusWord(progress: progress)
        }
        .padding(.top, 2)
    }

    var auditCaption: some View {
        Text("Auditoria")
            .font(AtlasFont.mono(9))
            .tracking(0.4)
            .foregroundStyle(AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    func auditProgressLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        Text("Planejado \(plan.steps.count) · executado \(min(progress.current, progress.total))/\(progress.total)")
            .font(AtlasFont.mono(10))
            // Soft gold-quiet plan audit meta.
            .foregroundStyle(AtlasTheme.accent.opacity(0.68))
            .monospacedDigit()
            .accessibilityHidden(true)
    }

    func auditStatusWord(progress: AtlasExecutionPlan.Progress) -> some View {
        Text(progress.isTerminal ? "terminal" : "em curso")
            .font(AtlasFont.mono(9))
            .foregroundStyle(progress.isTerminal ? AtlasTheme.domAutonomos : AtlasTheme.accent.opacity(0.62))
            .accessibilityHidden(true)
    }
}

// Detalhe do plano: toggle ferramentas/agentes/gates + flow chips + flex wrap.

extension PlanCard {
    @ViewBuilder
    func planDetailSection(plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
            planDetailToggleButton(plan: plan)
            if showDetail { planDetail(plan) }
        }
    }

    @ViewBuilder
    func planDetailToggleButton(plan: AtlasExecutionPlan) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showDetail.toggle()
            }
        } label: {
            // Ação fala em sans (mono é hash/recibo/meta — canon §C).
            Text(showDetail ? "Menos" : "Ferramentas · agentes · gates")
                .atlasSans(11, .medium)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .frame(minHeight: 48, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.planDetailToggle)
        .accessibilityLabel(showDetail ? "ocultar ferramentas agentes e gates" : "mostrar ferramentas agentes e gates")
        .accessibilityHint(showDetail ? "toque para recolher" : "toque para expandir")
        .accessibilityAddTraits(showDetail ? [.isButton, .isSelected] : .isButton)
    }

    func planDetail(_ plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            planAgentsChips(plan)
            planToolsChips(plan)
            planGatesChips(plan)
        }
        // Contain without fused label: chip rows speak their own labels.
        .accessibilityElement(children: .contain)
        .transition(reduceMotion ? .identity : .opacity)
    }

    @ViewBuilder
    func planAgentsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.agents.isEmpty {
            chipRow(label: "Agentes", items: plan.agents.map(\.title))
        }
    }

    @ViewBuilder
    func planToolsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty {
            chipRow(label: "Ferramentas", items: plan.tools.map(\.label))
        }
    }

    @ViewBuilder
    func planGatesChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.qualityGates.isEmpty {
            chipRow(label: "Gates", items: plan.qualityGates.map(\.label))
        }
    }

    func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AtlasFont.serif(12, .semibold))
                // Soft gold-quiet chip-row kicker.
                .foregroundStyle(AtlasTheme.accent.opacity(0.68))
                .accessibilityHidden(true)
            PlanFlowChips(items: items)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenChipRow(label: label, items: items))
    }
}

/// Chips em fluxo para agentes/ferramentas/gates.
/// Pai combina spoken via PlanCard.spokenChipRow; chips individuais silenciosos.
struct PlanFlowChips: View {
    let items: [String]
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            PlanFlexWrap(spacing: 6, lineSpacing: 6) {
                ForEach(items, id: \.self) { item in
                    flowChipCell(item)
                }
            }
            .accessibilityHidden(true)
        }
    }

    func flowChipCell(_ item: String) -> some View {
        Text(item)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.accent.opacity(0.72))
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(
                Capsule().fill(AtlasTheme.surface.opacity(0.55))
                    // Soft gold-quiet flow meta chip.
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
            )
            .atlasElevation(radius: 3, y: 1, opacity: 0.06)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

/// Layout que envolve os filhos em múltiplas linhas (sem dependência externa).
struct PlanFlexWrap: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let measured = measureFlexWrap(maxWidth: maxWidth, subviews: subviews)
        return CGSize(
            width: maxWidth == .infinity ? measured.width : maxWidth,
            height: measured.height
        )
    }

    func measureFlexWrap(
        maxWidth: CGFloat,
        subviews: Subviews
    ) -> (width: CGFloat, height: CGFloat) {
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (x, y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            placeFlexWrapSubview(sub, x: &x, y: &y, lineHeight: &lineHeight, bounds: bounds)
        }
    }

    func placeFlexWrapSubview(
        _ sub: LayoutSubview,
        x: inout CGFloat,
        y: inout CGFloat,
        lineHeight: inout CGFloat,
        bounds: CGRect
    ) {
        let size = sub.sizeThatFits(.unspecified)
        if x + size.width > bounds.maxX, x > bounds.minX {
            x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
        }
        sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
        x += size.width + spacing
        lineHeight = max(lineHeight, size.height)
    }
}

// Linha de passo do plano (dot, spine, title, pulse, a11y chrome).

struct PlanStepRowView: View {
    let step: AtlasExecutionPlan.Step
    let index: Int
    let total: Int
    let state: PlanCard.StepState
    let isLast: Bool
    let spokenLabel: String
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        stepRowBody
    }

    var stepRowBody: some View {
        applyStepPulse(
            stepRowA11yChrome(stepRowLayout)
        )
    }

    var stepRowLayout: some View {
        HStack(alignment: .top, spacing: 10) {
            stepDotColumn
            stepTitleColumn
            Spacer(minLength: 0)
        }
    }

    var stepTitleColumn: some View {
        Text(step.title)
            .font(AtlasFont.mono(10))
            // Soft gold-quiet pending steps; current/done keep hierarchy.
            .foregroundStyle(state == .pending ? AtlasTheme.accent.opacity(0.48)
                             : state == .current ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
            .lineLimit(2)
            .accessibilityHidden(true)
            .padding(.bottom, isLast ? 0 : 9)
    }

    func applyStepPulse<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                if state == .current && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: state == .current) { _, now in if !now { pulse = false } }
    }

    func stepRowA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(state == .current ? .isSelected : [])
            .accessibilityIdentifier(A11yID.planStep(index))
    }

    var stepDotColumn: some View {
        VStack(spacing: 0) {
            stepDotMark
            stepDotSpine
        }
        .frame(width: 13)
        .accessibilityHidden(true)
    }

    func dotFill(_ s: PlanCard.StepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }

    @ViewBuilder
    var stepDotMark: some View {
        ZStack {
            Circle().fill(dotFill(state)).frame(width: 13, height: 13)
                .opacity(state == .current && pulse && !reduceMotion ? 0.55 : 1)
                // Soft gold bloom for live/done steps — pending stays quiet.
                .shadow(
                    color: AtlasTheme.accent.opacity(
                        state == .current ? 0.45 : (state == .done ? 0.28 : 0)
                    ),
                    radius: state == .current ? 4 : 2,
                    y: 0
                )
            if state == .done {
                Image(systemName: "checkmark").atlasSans(7, .bold)
                    .foregroundStyle(AtlasTheme.bg)
            } else if state == .current {
                Circle().fill(AtlasTheme.bg).frame(width: 5, height: 5)
            }
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    var stepDotSpine: some View {
        if !isLast {
            Rectangle().fill(AtlasTheme.accent.opacity(state == .pending ? 0.15 : 0.35))
                .frame(width: 1.5).frame(maxHeight: .infinity)
        }
    }
}

// C19 / cena 02 — "comparar versões" só com planRevisions tipados.

extension PlanCard {
    @ViewBuilder
    func revisionToggle(plan: AtlasExecutionPlan) -> some View {
        let count = meaningfulRevisions.count
        revisionToggleControl(plan: plan, count: count)
        if showRevisions {
            PlanRevisionCompare(plan: plan, revisions: meaningfulRevisions)
                .transition(reduceMotion ? .identity : .opacity)
        }
    }

    func revisionToggleControl(plan: AtlasExecutionPlan, count: Int) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showRevisions.toggle()
            }
        } label: {
            // Ação fala em sans (mono é hash/recibo/meta — canon §C).
            Text(showRevisions ? "Ocultar versões" : "Comparar versões · \(count)")
                .atlasSans(11, .medium)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .frame(minHeight: 48, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(spokenRevisionToggle(expanded: showRevisions, count: count))
        .accessibilityHint(showRevisions ? "toque para ocultar" : "toque para expandir")
        .accessibilityAddTraits(showRevisions ? [.isButton, .isSelected] : .isButton)
    }
}

struct PlanRevisionCompare: View {
    let plan: AtlasExecutionPlan
    let revisions: [AtlasTraceGovernance.PlanRevision]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            comparisonBody
            revisionArchiveList
        }
    }

    enum RevisionTone { case removed, added }

    struct RevisionComparison {
        let revision: AtlasTraceGovernance.PlanRevision
        let left: [String]
        let entered: [String]
        var hasChanges: Bool { !left.isEmpty || !entered.isEmpty }
    }

    var latestComparison: RevisionComparison? {
        guard let revision = revisions.last(where: { !$0.stepTitles.isEmpty }) else { return nil }
        let current = plan.steps.map(\.title)
        let archived = revision.stepTitles
        return RevisionComparison(
            revision: revision,
            left: archived.filter { !current.contains($0) },
            entered: current.filter { !archived.contains($0) }
        )
    }

    func hasArchiveMetadata(_ rev: AtlasTraceGovernance.PlanRevision) -> Bool {
        rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
    }

    func editorialArchivedAt(_ raw: String) -> String {
        if let tIndex = raw.firstIndex(of: "T") {
            return String(raw[..<tIndex])
        }
        return raw
    }

    // MARK: Compare body

    @ViewBuilder
    var comparisonBody: some View {
        if let comparison = latestComparison, comparison.hasChanges {
            VStack(alignment: .leading, spacing: 7) {
                Text("v\(comparison.revision.revision) arquivado → plano atual")
                    .font(AtlasFont.mono(9, .medium))
                    .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                    .accessibilityHidden(true)
                comparisonLeftList
                comparisonEnteredList
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                    .fill(AtlasTheme.bgRecessed.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                    // Soft gold-quiet comparison panel.
                    .stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1)
            )
            .atlasElevation(radius: 6, y: 2, opacity: 0.1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(comparisonAccessibilityLabel(comparison))
        }
    }

    @ViewBuilder
    var comparisonLeftList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.left.isEmpty {
            revisionList(label: "saíram", items: comparison.left, tone: .removed)
        }
    }

    @ViewBuilder
    var comparisonEnteredList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.entered.isEmpty {
            revisionList(label: "entraram", items: comparison.entered, tone: .added)
        }
    }

    func comparisonAccessibilityLabel(_ comparison: RevisionComparison) -> String {
        var parts = ["comparação do plano, versão \(comparison.revision.revision) arquivada"]
        if !comparison.left.isEmpty {
            parts.append("\(comparison.left.count) passos saíram")
        }
        if !comparison.entered.isEmpty {
            parts.append("\(comparison.entered.count) passos entraram")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Lists

    func revisionList(label: String, items: [String], tone: RevisionTone) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AtlasFont.serif(12, .semibold))
                .foregroundStyle(tone == .removed ? AtlasTheme.domOperacional.opacity(0.9) : AtlasTheme.domAutonomos.opacity(0.95))
                .accessibilityHidden(true)
            revisionListItems(items: items, tone: tone)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(items.count) passo\(items.count == 1 ? "" : "s")")
    }

    @ViewBuilder
    func revisionListItems(items: [String], tone: RevisionTone) -> some View {
        ForEach(items, id: \.self) { item in
            revisionBulletRow(item: item, tone: tone)
        }
    }

    func revisionBulletRow(item: String, tone: RevisionTone) -> some View {
        Text("• \(item)")
            .atlasSans(12)
            .foregroundStyle(
                tone == .removed
                    ? AtlasTheme.domOperacional.opacity(0.75)
                    : AtlasTheme.domAutonomos.opacity(0.9)
            )
            .strikethrough(tone == .removed, color: AtlasTheme.domOperacional.opacity(0.55))
            .lineLimit(2)
            .accessibilityHidden(true)
    }

    // MARK: Archive

    @ViewBuilder
    var revisionArchiveList: some View {
        if revisions.contains(where: hasArchiveMetadata) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(revisions) { rev in
                    if hasArchiveMetadata(rev) {
                        revisionArchiveRow(rev)
                    }
                }
            }
        }
    }

    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            revisionArchiveHeader(rev)
            revisionArchiveMeta(rev)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                .fill(AtlasTheme.surface.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                // Soft gold-quiet revision archive card.
                .stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1)
        )
        .atlasElevation(radius: 4, y: 1, opacity: 0.08)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }

    func revisionArchiveHeader(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        HStack(spacing: 6) {
            Text("v\(rev.revision) arquivado")
                .font(AtlasFont.mono(10))
                // Soft gold-quiet revision archive header.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .accessibilityHidden(true)
            if let iteration = rev.iteration {
                Text("iter \(iteration)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        revisionArchiveWhen(rev)
        revisionArchiveSteps(rev)
    }

    @ViewBuilder
    func revisionArchiveReason(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let reason = rev.reason, !reason.isEmpty {
            Text(rev.humanReason)
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func revisionArchiveWhen(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let archivedAt = rev.archivedAt {
            Text(editorialArchivedAt(archivedAt))
                .font(AtlasFont.mono(9))
                // Soft gold-quiet archive timestamp.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func revisionArchiveSteps(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if !rev.stepTitles.isEmpty {
            Text(rev.stepTitles.joined(separator: " · "))
                .font(AtlasFont.mono(9))
                // Soft gold-quiet archived step titles.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }

    func revisionArchiveAccessibilityLabel(_ rev: AtlasTraceGovernance.PlanRevision) -> String {
        var parts = ["plano versão \(rev.revision) arquivado"]
        if let reason = rev.reason, !reason.isEmpty {
            parts.append(rev.humanReason)
        }
        if let archivedAt = rev.archivedAt {
            parts.append("em \(editorialArchivedAt(archivedAt))")
        }
        if !rev.stepTitles.isEmpty {
            parts.append("\(rev.stepTitles.count) passos")
        }
        return parts.joined(separator: ", ")
    }
}


// Cycle 044 fuse → ExecutionProof.swift

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    var body: some View {
        proofChrome { proofStack }
    }
}

extension ExecutionProof {
    func proofChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.35))
                    // Soft gold-quiet proof panel chrome.
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
            )
            .atlasElevation(radius: 6, y: 2, opacity: 0.1)
    }
}

extension ExecutionProof {
    var proofStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
            if open {
                expandedProofContent
            }
        }
    }
}

extension ExecutionProof {
    /// Passos, decide, quality ou artefatos reais — nunca card vazio pós-conclusão.
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(Self.hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }
}

extension ExecutionProof {
    var collapsedHeader: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { open.toggle() }
        } label: {
            collapsedHeaderLabel
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenCollapsed(expanded: open))
        .accessibilityHint(open ? "toque para fechar a prova" : "toque para expandir a prova")
        .accessibilityAddTraits(open ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(A11yID.executionProof)
    }
}

extension ExecutionProof {
    var collapsedHeaderLabel: some View {
        HStack(spacing: 10) {
            Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                // Soft gold bloom — marks completed work without faking a pulse.
                .shadow(color: AtlasTheme.accent.opacity(0.35), radius: 4, y: 0)
                .accessibilityHidden(true)
            collapsedHeaderSummary
            Spacer(minLength: 0)
            Text(open ? "Fechar" : "Abrir")
                .font(AtlasFont.serif(13)).foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    @ViewBuilder
    var collapsedHeaderSummary: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Obra concluída")
                .font(AtlasFont.serif(14, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if !summaryLine.isEmpty {
                Text(summaryLine)
                    // Soft gold-quiet collapsed proof summary.
                    .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.accent.opacity(0.68))
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension ExecutionProof {
    /// Campos publicados pelo ledger — nunca só o rótulo «atlas decide».
    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }
}

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            artifactsButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpenArtifacts(traceId)
                } label: {
                    artifactsButtonLabel(count: artifactItems.count)
                },
                count: artifactItems.count
            )
        }
    }
}

extension ExecutionProof {
    func artifactsButtonA11y<Content: View>(_ content: Content, count: Int) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel("Artefatos desta execução, \(count)")
            .accessibilityHint("Abre a lista de artefatos deste trace")
            .accessibilityAddTraits(.isButton)
    }
}

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.accent.opacity(0.42))
            .accessibilityHidden(true)
    }
}

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            artifactsButtonLead(count: count)
            artifactsChevron
        }
        .frame(minHeight: 48, alignment: .leading)
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    func artifactsButtonLead(count: Int) -> some View {
        HStack(spacing: 6) {
            Text("⎘")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            Text("Artefatos (\(count))")
                .font(AtlasFont.mono(12))
                // Soft gold-quiet artifacts header.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
            Spacer()
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            // Soft gold-breath divider before decision meta.
            Divider().overlay(AtlasTheme.accent.opacity(0.22)).accessibilityHidden(true)
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    func decisionSummaryRow(_ d: AtlasDecisionSummary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                .accessibilityHidden(true)
            Text(decideLine(d))
                // Soft gold-quiet decision meta.
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent.opacity(0.7))
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(decisionSpoken(d))
    }
}

extension ExecutionProof {
    @ViewBuilder
    var qualityBlock: some View {
        if let q = bubble.qualitySummary {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .atlasSans(11).foregroundStyle(qualityColor(q)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(qualityLine(q))
                    // Soft gold-quiet quality meta (seal color stays status).
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent.opacity(0.7))
            }
            .accessibilityLabel(qualitySpoken(q))
        }
    }

    /// Cor do selo de qualidade — RECONSTRUÍDO pós-merge (vivia private no
    func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }

}

extension ExecutionProof {
    @ViewBuilder
    func decisionReason(_ d: AtlasDecisionSummary) -> some View {
        if let r = d.reason, !r.isEmpty {
            Text("\"\(r)\"")
                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.leading, 23)
                .accessibilityLabel("Motivo, \(r)")
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            activityRows
            decisionBlock
            qualityBlock
            artifactsBlock
        }
        .padding(.top, 8)
        .padding(.leading, 4)
        .transition(reduceMotion ? .identity : .opacity)
        .onChange(of: bubble.activities.count) {
            replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
        }
    }
}

extension ExecutionProof {
    func activityRowCell(index: Int, act: AtlasAgentActivity) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            activityRowCopy(act)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
        )
    }
}

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                activityRowCell(index: index, act: act)
            }
        }
    }
}

extension ExecutionProof {
    func activityRowCopy(_ act: AtlasAgentActivity) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(act.title)
                .font(AtlasFont.serif(13)).foregroundStyle(AtlasTheme.textSecondary)
            if let d = act.detail, !d.isEmpty {
                // Soft gold-quiet activity detail meta.
                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent.opacity(0.58))
                    .lineLimit(2).truncationMode(.middle)
            }
        }
    }
}

extension ExecutionProof {
    func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }
}

extension ExecutionProof {
    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }
}

extension ExecutionProof {
    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func spokenCollapsedMetricsParts() -> [String] {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if bubble.decisionSummary.map(Self.hasDecisionSurface) == true { parts.append("decisão do atlas") }
        if bubble.qualitySummary != nil { parts.append("avaliação de qualidade") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts
    }
}

extension ExecutionProof {
    var spokenCollapsed: String {
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        (
            ["prova da execução", expanded ? "expandida" : "recolhida"]
            + spokenCollapsedMetricsParts()
        ).joined(separator: ", ")
    }
}

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }
}

extension ExecutionProof {
    var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: " · ")
    }
}

extension ExecutionProof {
    func decisionSpokenRoute(_ d: AtlasDecisionSummary) -> [String] {
        var parts = ["decisão do atlas"]
        if let m = d.routeMode { parts.append("modo \(m)") }
        if let p = d.selectedProvider { parts.append("provedor \(p)") }
        return parts
    }
}

extension ExecutionProof {
    func decisionSpoken(_ d: AtlasDecisionSummary) -> String {
        var parts = decisionSpokenRoute(d)
        if let c = d.confidenceScore { parts.append("confiança \(String(format: "%.2f", c))") }
        if d.wasOverridden { parts.append("substituída manualmente") }
        if let r = d.reason, !r.isEmpty { parts.append("motivo \(r)") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }
}

extension ExecutionProof {
    func replaySliderControl(stampedCount: Int) -> some View {
        Slider(value: Binding(
            get: { Double(replayIndex) },
            set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
        ), in: 0...Double(stampedCount - 1), step: 1)
        .tint(AtlasTheme.accent)
        .accessibilityLabel("Scrubber de replay da execução")
        .accessibilityValue("passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}

extension ExecutionProof {
    func replayStepperControl(stampedCount: Int) -> some View {
        Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
            get: { replayIndex },
            set: { replayIndex = min(max(0, $0), stampedCount - 1) }
        ), in: 0...(stampedCount - 1))
        .labelsHidden()
        .accessibilityLabel("Replay da execução, passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}

extension ExecutionProof {
    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            replayStepperControl(stampedCount: stampedCount)
        } else {
            replaySliderControl(stampedCount: stampedCount)
        }
    }
}

extension ExecutionProof {
    func replayScrubberChrome(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberHeader(index: index, total: total, selected: selected)
            replayControls(stampedCount: total)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
        // Soft gold-quiet replay scrubber chrome.
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
        // Scrubber rides above proof chrome without competing with primary CTAs.
        .atlasElevation(radius: 4, y: 1, opacity: 0.08)
        .accessibilityIdentifier(A11yID.executionReplayScrubber)
    }
}

extension ExecutionProof {
    @ViewBuilder
    var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            replayScrubberChrome(index: index, total: stamped.count, selected: selected)
        } else if !bubble.activities.isEmpty {
            Text("Replay indisponível · eventos sem timestamps")
                .font(AtlasFont.mono(10))
                // Soft gold-quiet replay honesty meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .accessibilityLabel("Replay indisponível porque os eventos não têm timestamps")
        }
    }
}

extension ExecutionProof {
    func replayScrubberTitle(index: Int, total: Int) -> some View {
        HStack {
            Text("Replay")
                .font(AtlasFont.mono(10))
                .tracking(0.4)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Spacer()
            Text("\(index + 1)/\(total)")
                .font(AtlasFont.mono(10))
                // Soft gold-quiet replay counter.
                .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionProof {
    func replayScrubberHeader(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberTitle(index: index, total: total)
            replayScrubberMeta(selected: selected)
        }
    }
}

extension ExecutionProof {
    func replayScrubberMeta(selected: (activity: AtlasAgentActivity, date: Date)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selected.activity.title)
                .font(AtlasFont.mono(10, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
            Text(selected.activity.occurredAt ?? "")
                .font(AtlasFont.mono(10))
                // Soft gold-quiet replay timestamp.
                .foregroundStyle(AtlasTheme.accent.opacity(0.58))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}


// Cycle 044 fuse → ExecutionStateCard.swift

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        stateCardChrome { stateCardStack }
    }
}

// Action buttons, style, choices, steer, retry. Cycle 020 fuse.

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }

    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }

    @ViewBuilder
    var choiceButtonsStack: some View {
        if let choiceJobId = effectiveChoiceJobId, !state.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(state.actions) { action in
                    choiceActionButton(action, choiceJobId: choiceJobId)
                }
            }
        }
    }

    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
        Button {
            // Medium: server-declared execution choice is a governed commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onChoose(choiceJobId, action.id)
        } label: {
            Text(action.title)
                .font(AtlasFont.mono(10, .semibold))
                .lineLimit(1)
                .padding(.horizontal, 11).padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 48)
                .contentShape(Rectangle())
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: action.style,
            reduceMotion: reduceMotion
        ))
        .accessibilityIdentifier(A11yID.executionActionChoice(action.id))
        .accessibilityLabel(action.title)
        .accessibilityHint("Ação declarada pelo servidor")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(action.style == .primary || action.style == .destructive ? 9 : 0)
    }

    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackAction(retryableJobId)
        }
    }

    @ViewBuilder
    func retryFallbackAction(_ jobId: JobID) -> some View {
        retryFallbackA11y(
            Button {
                // Medium: re-queue failed job is governed.
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                onRetry(jobId)
            } label: {
                retryFallbackLabel
            }
        )
    }

    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel("Retomar execução a partir do último checkpoint")
            .accessibilityHint("Reenfileira o job que falhou")
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(9)
    }

    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(AtlasFont.mono(10, .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
    }

    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }

    @ViewBuilder
    var steerActionButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSteer?()
        } label: {
            steerButtonLabel
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: .secondary,
            reduceMotion: reduceMotion
        ))
        .accessibilityLabel("Redirecionar esta execução")
        .accessibilityHint("Abre instrução para o próximo checkpoint seguro")
        .accessibilityAddTraits(.isButton)
    }

    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(AtlasFont.mono(10, .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
    }
}

/// Estilo dos botões de ação do ExecutionStateCard.
struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle
    var reduceMotion: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            // Execution CTAs share floating chrome with strip/toast planes.
            .atlasElevation(
                radius: 8,
                y: 2,
                opacity: configuration.isPressed ? 0.08 : elevationOpacity
            )
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }

    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }

    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }

    var elevationOpacity: Double {
        switch style {
        case .primary: return 0.18
        case .destructive: return 0.14
        case .secondary: return 0.1
        }
    }
}

// Awaiting/failed leave/retry predicates + spoken assembly. Cycle 020 fuse.

extension ExecutionStateCard {
    static func copyMentionsCanLeave(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        return text.contains("pode sair")
    }
}

extension ExecutionStateCard {
    /// Cena 13: o motivo falado vem do `detail` publicado pelo servidor.
    var spokenFailureReason: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo: \(detail)"
    }

    var failureReasonA11y: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo da falha: \(detail)"
    }
}

extension ExecutionStateCard {
    /// «Pode sair» só quando o contrato pausa o timer ou o servidor já publicou essa copy.
    var leaveScreenKicker: String? {
        guard state.kind == .awaitingExternal else { return nil }
        if Self.copyMentionsCanLeave(state.detail) || Self.copyMentionsCanLeave(state.title) {
            return nil
        }
        guard state.timer?.timing == .paused else { return nil }
        return "Você pode sair desta tela"
    }
}

extension ExecutionStateCard {
    var showsRetryFallback: Bool {
        state.kind == .failed
            && state.actions.isEmpty
            && retryableJobId != nil
    }
}

extension ExecutionStateCard {
    func spokenMetaParts(into parts: inout [String]) {
        if let kicker = leaveScreenKicker { parts.append(kicker) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
    }
}

extension ExecutionStateCard {
    func spokenReasonParts(into parts: inout [String]) {
        if let reason = spokenFailureReason {
            parts.append(reason)
        } else if let detail = state.detail {
            parts.append(detail)
        }
    }
}

extension ExecutionStateCard {
    func spokenDetailParts(into parts: inout [String]) {
        spokenReasonParts(into: &parts)
        spokenMetaParts(into: &parts)
    }
}

extension ExecutionStateCard {
    func spokenSummaryLead(into parts: inout [String]) {
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
    }
}

extension ExecutionStateCard {
    func spokenSummaryTail(into parts: inout [String]) {
        spokenDetailParts(into: &parts)
        spokenTimingParts(into: &parts)
    }
}

extension ExecutionStateCard {
    var spokenSummaryText: String {
        var parts: [String] = []
        spokenSummaryLead(into: &parts)
        spokenSummaryTail(into: &parts)
        return parts.joined(separator: ". ")
    }
}

extension ExecutionStateCard {
    func spokenDeadlineParts(into parts: inout [String]) {
        if let deadline = publishedExternalDeadline { parts.append("próxima mudança \(deadline)") }
        if let action = spokenActionFragment { parts.append(action) }
    }
}

extension ExecutionStateCard {
    func spokenTimerPart(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
    }
}

extension ExecutionStateCard {
    func spokenTimingParts(into parts: inout [String]) {
        spokenTimerPart(into: &parts)
        spokenDeadlineParts(into: &parts)
    }
}

extension ExecutionStateCard {
    var spokenSummary: String { spokenSummaryText }
}

extension ExecutionStateCard {
    var spokenActionFragment: String? {
        if !state.actions.isEmpty {
            return "\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis"
        }
        if showsRetryFallback {
            return "retomar disponível"
        }
        return nil
    }
}

extension ExecutionStateCard {
    /// Prazo só na espera externa; o campo `deadline` do contrato não vale para outros kinds.
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    /// Job para ações declaradas: atenção usa `jobId`; falha usa `retryableJobId` real.
    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
    }
}

// Presentation: chrome, header, meta, detail, icon, badge, timers, tint, stack. Cycle 020 fuse.

extension ExecutionStateCard {
    func stateCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.card)
                    .fill(AtlasTheme.surface.opacity(0.68))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(tint.opacity(0.42), lineWidth: 1))
            )
            .atlasElevation(radius: 10, y: 3, opacity: 0.16)
            // Contain without fused label: choice/retry/steer buttons stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.executionStateCard)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var detailLine: some View {
        if let detail = state.detail {
            Text(detail)
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    static func shouldDisplay(state: AtlasExecutionPresentationState) -> Bool {
        if state.kind == .completed,
           state.actions.isEmpty,
           state.detail == nil,
           state.checkpoint == nil,
           state.deadline == nil {
            return false
        }
        return true
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var stateHeaderBadge: some View {
        if let badge = kindBadge {
            Text(badge)
                .font(AtlasFont.mono(10)).tracking(0.3)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    var stateHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .atlasSans(13, .semibold)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(state.title)
                .font(AtlasFont.serif(13, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            stateHeaderBadge
        }
    }
}

extension ExecutionStateCard {
    var iconWait: String? {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var iconAttention: String? {
        if let wait = iconWait { return wait }
        switch state.kind {
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var iconTerminal: String {
        switch state.kind {
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        default: return iconAttention ?? "exclamationmark.shield"
        }
    }
}

extension ExecutionStateCard {
    var icon: String {
        iconAttention ?? iconTerminal
    }

    /// Pure formatter — nonisolated so spoken helpers outside MainActor can call it.
    nonisolated static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

extension ExecutionStateCard {
    var kindBadgeWait: String? {
        switch state.kind {
        case .attentionRequired: return "Pausado"
        case .awaitingExternal: return "Aguardando"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var kindBadgeAttention: String? {
        if let wait = kindBadgeWait { return wait }
        switch state.kind {
        case .recovering: return "Reconectando"
        case .replanning: return "Replanejando"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    /// Selo 1:1 com `kind` — nunca copy inventada além do mapeamento canônico.
    var kindBadge: String? {
        switch state.kind {
        case .failed: return "Falhou"
        case .completed: return nil
        default: return kindBadgeAttention
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaKickerLines: some View {
        if let kicker = leaveScreenKicker {
            Text(kicker)
                .font(AtlasFont.mono(10, .semibold))
                // Soft gold-quiet leave-screen kicker.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .accessibilityHidden(true)
        }
        if let checkpoint = state.checkpoint {
            Text("Checkpoint · \(checkpoint)")
                .font(AtlasFont.mono(10))
                // Soft gold-quiet checkpoint meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaLines: some View {
        metaKickerLines
        timerMetaLines
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var deadlineMetaLine: some View {
        if let deadline = publishedExternalDeadline {
            Text("Próxima mudança: \(deadline)")
                .font(AtlasFont.mono(10))
                // Soft gold-quiet external deadline meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var frozenTimerLine: some View {
        if let frozen = frozenTimerText {
            Text(frozen)
                .font(AtlasFont.mono(10))
                // Soft gold-quiet frozen timer.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var recoveringTimerLine: some View {
        if frozenTimerText == nil, let active = recoveringTimerText {
            Text(active)
                .font(AtlasFont.mono(10))
                // Soft gold-quiet recovering timer.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var timerMetaLines: some View {
        frozenTimerLine
        recoveringTimerLine
        deadlineMetaLine
    }
}

extension ExecutionStateCard {
    var spokenKindWait: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var spokenKindAttention: String? {
        if let wait = spokenKindWait { return wait }
        switch state.kind {
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var spokenKindTerminal: String {
        switch state.kind {
        case .failed: return "execução falhou"
        case .completed: return "execução concluída"
        default: return spokenKindAttention ?? "execução"
        }
    }
}

extension ExecutionStateCard {
    var spokenKind: String? {
        spokenKindAttention ?? spokenKindTerminal
    }
}

extension ExecutionStateCard {
    var tintAttention: Color? {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var tint: Color {
        if let attention = tintAttention { return attention }
        switch state.kind {
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        default: return AtlasTheme.accent
        }
    }
}

extension ExecutionStateCard {
    var stateCardStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            stateHeader
            detailLine
            metaLines
            actionButtons
        }
    }
}

extension ExecutionStateCard {
    /// Timer congelado (‖) — paridade Island/Lock para `.attentionRequired` e
    /// `.awaitingExternal` quando o servidor publica `timing: paused`.
    var frozenTimerText: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "‖ \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}

extension ExecutionStateCard {
    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}

extension ExecutionStateCard {
    var recoveringTimerText: String? {
        guard state.kind == .recovering, let timer = state.timer else { return nil }
        return "ativo \(Self.clock(timer.elapsedActiveMilliseconds))"
    }

    var spokenTimerFragment: String? {
        frozenTimerA11y ?? recoveringTimerText
    }
}


// Cycle 044 fuse → LiveTimeline.swift

extension LiveTimeline {
    @ViewBuilder
    var timelineBody: some View {
        if baseRows.isEmpty {
            EmptyView()
        } else if rows.isEmpty {
            filterSilenceSurface
        } else {
            timelineSurface
        }
    }
}

// A narrativa viva da execução: cada linha espelha um `AtlasAgentActivity`
// real do contrato C5. Sem agregação inventada, sem placeholder quando vazio.
struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool
    @State var filter: TimelineReadFilter = .all

    var body: some View {
        timelineBody
    }
}

extension TimelineReadFilter {
    func applyAllOrP90(to rows: [NarrativeRow]) -> [NarrativeRow] {
        switch self {
        case .all:
            return rows
        case .p90:
            return rows.filter(\.isP90)
        default:
            return rows
        }
    }
}

extension TimelineReadFilter {
    func applyStyleFilter(to rows: [NarrativeRow]) -> [NarrativeRow]? {
        switch self {
        case .intent:
            return rows.filter { $0.style == .intent }
        case .tools:
            return rows.filter { $0.style == .single }
        default:
            return nil
        }
    }
}

extension TimelineReadFilter {
    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        if let styled = applyStyleFilter(to: rows) { return styled }
        return applyAllOrP90(to: rows)
    }
}

extension TimelineFilterChips {
    func filterChipA11y<Content: View>(
        _ content: Content,
        option: TimelineReadFilter,
        active: Bool,
        count: Int
    ) -> some View {
        content
            .accessibilityLabel(LiveTimelineA11y.spokenFilterChip(option,
                                                                  count: count,
                                                                  active: active,
                                                                  silent: active && filterSilence))
            .accessibilityHint(LiveTimelineA11y.spokenFilterHint())
            .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
    }
}

extension TimelineFilterChips {
    func filterChipAction(_ option: TimelineReadFilter) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct)) {
            filter = option
        }
    }
}

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
        filterChipA11y(
            Button {
                filterChipAction(option)
            } label: {
                chipLabel(option, active: active)
            }
            .buttonStyle(PressableScale()),
            option: option,
            active: active,
            count: count
        )
    }
}

extension TimelineFilterChips {
    func chipLabel(_ option: TimelineReadFilter, active: Bool) -> some View {
        Text(option.label)
            .font(AtlasFont.mono(9))
            // Soft gold-quiet inactive filters — active stays full accent.
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.55))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minHeight: 48) // HIG 44+; match filter chip breath
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.bgRecessed))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.goldBorder.opacity(0.35), lineWidth: 1))
            .atlasElevation(radius: 4, y: 1, opacity: active ? 0.12 : 0.04)
            .contentShape(Capsule())
    }
}

extension TimelineFilterChips {
    @ViewBuilder
    var filterChipLoop: some View {
        ForEach(TimelineReadFilter.allCases) { option in
            let active = option == filter
            let count = option.apply(to: baseRows).count
            filterChipButton(option, active: active, count: count)
        }
    }
}

extension TimelineReadFilter {
    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }
}

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }
}

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            filterChipLoop
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: filter)
    }
}

extension NarrativeRowView {
    var narrativeA11y: some View {
        narrativeBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(LiveTimelineA11y.spokenRow(row: row,
                                                           index: index,
                                                           total: total,
                                                           isCurrent: isCurrent))
            .accessibilityValue(LiveTimelineA11y.rowValue(index: index, total: total, isCurrent: isCurrent))
            .accessibilityAddTraits(currentTraits)
    }
}

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
            narrativeSpine
            narrativeTextStack
            Spacer(minLength: 0)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDetailLine: some View {
        if let detail = row.detail, !detail.isEmpty {
            Text(detail).font(AtlasFont.mono(11))
                // Soft gold-quiet narrative detail meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.58))
                .lineLimit(row.style == .intent ? 2 : 1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeP90Badge: some View {
        if row.isP90 {
            Text("p90")
                .font(AtlasFont.mono(9, .medium))
                .foregroundStyle(AtlasTheme.domOperacional)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
                .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                .atlasElevation(radius: 3, y: 1, opacity: 0.08)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationChip: some View {
        if let duration = row.durationMs {
            HStack(spacing: 5) {
                Text("Δ \(humanDuration(duration))")
                    .font(AtlasFont.mono(10, .medium))
                    .foregroundStyle(
                        row.isP90
                            ? AtlasTheme.domOperacional
                            : AtlasTheme.accent.opacity(0.75)
                    )
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                narrativeP90Badge
            }
            .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationMeta: some View {
        narrativeDurationChip
    }
}

extension NarrativeRowView {
    func narrativePulseLifecycle() -> some View {
        narrativeA11y
            .onAppear {
                if isCurrent && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, single }
    let id: String
    let style: Style
    let title: String
    let detail: String?
    let occurredAt: Date?
    var durationMs: Int? = nil
    var isP90: Bool = false
}

extension NarrativeRowView {
    var narrativeSpine: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                .frame(width: 7, height: 7)
                .opacity(isCurrent && pulse && !reduceMotion ? 0.4 : 1)
                // Live step blooms; history nodes stay quiet.
                .shadow(
                    color: AtlasTheme.accent.opacity(isCurrent ? 0.5 : 0.15),
                    radius: isCurrent ? 4 : 1,
                    y: 0
                )
                .padding(.top, 5)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 10)
        .accessibilityHidden(true)
    }
}

extension NarrativeRowView {
    var narrativeTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(row.style == .intent ? AtlasFont.serif(13) : AtlasFont.mono(11))
                .foregroundStyle(row.style == .intent
                    ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                    // Soft gold-quiet non-intent narrative titles.
                    : AtlasTheme.accent.opacity(0.58))
                .lineLimit(row.style == .intent ? 3 : 2)
                .accessibilityHidden(true)
            narrativeDetailLine
            narrativeDurationMeta
        }
        .padding(.bottom, 10)
    }
}

extension NarrativeRowView {
    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}

struct NarrativeRowView: View {
    let row: NarrativeRow
    let index: Int
    let total: Int
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        narrativePulseLifecycle()
    }
}

enum LiveTimelineA11y {
    static func spokenSectionLabel(stepCount: Int) -> String {
        "Orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }
}

extension LiveTimelineA11y {
    static func spokenFilterChip(_ filter: TimelineReadFilter,
                                 count: Int,
                                 active: Bool,
                                 silent: Bool) -> String {
        "Filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }
}

extension LiveTimelineA11y {
    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }
}

extension LiveTimelineA11y {
    static func spokenFilterHint() -> String {
        "Altera quais passos da orquestra são exibidos"
    }
}

extension LiveTimelineA11y {
    static func spokenRow(row: NarrativeRow, index: Int, total: Int, isCurrent: Bool) -> String {
        var parts = ["Passo \(index + 1) de \(total)", row.title]
        if let detail = row.detail, !detail.isEmpty { parts.append(detail) }
        if let duration = row.durationMs {
            parts.append("duração \(humanDuration(duration))")
            if row.isP90 { parts.append("acima do p90") }
        }
        if isCurrent { parts.append("passo atual da orquestra") }
        return parts.joined(separator: ", ")
    }
}

extension LiveTimelineA11y {
    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent ? "Passo \(index + 1) de \(total), em andamento" : "Passo \(index + 1) de \(total)"
    }
}

func activityIconIntent(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    default: return nil
    }
}

func activityIconTerminal(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .completed: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .progress: return "ellipsis.circle"
    default: return nil
    }
}

func activityIconTool(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .executing: return "chevron.left.forwardslash.chevron.right"
    case .reading: return "doc.text"
    case .editing: return "pencil.line"
    case .verifying: return "checkmark.seal"
    case .evidence: return "tray.full"
    default: return nil
    }
}

/// Ícone por kind de atividade (vocabulário estável do contrato C5).

func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    activityIconIntent(kind)
        ?? activityIconTool(kind)
        ?? activityIconTerminal(kind)
        ?? "ellipsis.circle"
}

func annotateNarrativeDurations(_ rows: inout [NarrativeRow]) {
    guard rows.count > 1 else { return }
    for index in rows.indices.dropLast() {
        guard let start = rows[index].occurredAt,
              let end = rows[rows.index(after: index)].occurredAt else { continue }
        rows[index].durationMs = max(0, Int(end.timeIntervalSince(start) * 1000))
    }
    annotateNarrativeP90(&rows)
}

func isNarrativeIntentKind(_ kind: AtlasAgentActivity.Kind) -> Bool {
    [.understanding, .planning, .reasoning, .permission,
     .completed, .warning, .evidence, .verifying].contains(kind)
}

func annotateNarrativeP90(_ rows: inout [NarrativeRow]) {
    let durations = rows.compactMap(\.durationMs).sorted()
    guard !durations.isEmpty else { return }
    let p90Index = min(durations.count - 1, Int(ceil(Double(durations.count) * 0.9)) - 1)
    let threshold = durations[max(0, p90Index)]
    guard threshold > 0 else { return }
    for index in rows.indices {
        rows[index].isP90 = (rows[index].durationMs ?? 0) >= threshold
    }
}

extension LiveTimeline {
    var baseRows: [NarrativeRow] { narrativeRows(from: activities) }
    var rows: [NarrativeRow] { filter.apply(to: baseRows) }
    var showsFilterChips: Bool { baseRows.count > 2 }
    var filterSilence: Bool { showsFilterChips && filter != .all && rows.isEmpty }
}

func narrativeRowMap(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    activities.map { activity in
        NarrativeRow(
            id: activity.id,
            style: isNarrativeIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
}

// Cada passo espelha um `AtlasAgentActivity` real; a casca não inventa títulos.

/// Projeta atividades reais 1:1 — sem agregar nem renomear ferramentas.
func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows = narrativeRowMap(from: activities)
    annotateNarrativeDurations(&rows)
    return rows
}

extension LiveTimeline {
    func timelineScrollToLast(_ proxy: ScrollViewProxy) {
        guard let last = rows.last?.id else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct)) {
            proxy.scrollTo(last, anchor: .bottom)
        }
    }
}

extension LiveTimeline {
    var timelineScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                timelineRows
            }
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) { timelineScrollToLast(proxy) }
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: rows.count)
        }
    }
}

extension LiveTimeline {
    var timelineRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                NarrativeRowView(row: row,
                                 index: idx,
                                 total: rows.count,
                                 isCurrent: idx == rows.count - 1,
                                 isLast: idx == rows.count - 1,
                                 reduceMotion: reduceMotion)
                    .id(row.id)
                    .transition(reduceMotion ? .opacity
                                : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.trailing, 4)
    }
}

extension LiveTimeline {
    func filterSilenceA11y<V: View>(_ content: V) -> some View {
        content
            // Contain without fused label: filter chips stay selectable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
    }
}

extension LiveTimeline {
    @ViewBuilder
    var filterSilenceSurface: some View {
        if showsFilterChips {
            filterSilenceA11y(
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: filterSilence)
            )
        }
    }
}

extension LiveTimeline {
    var timelineSurface: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsFilterChips {
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: false)
            }
            timelineScroll
        }
        // Contain without fused label: chips + step rows stay focusable.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.liveTimeline)
    }
}


// Cycle 044 fuse → ConversationSheets.swift

extension View {
    func conversationComposerSheets(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifierForward(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

extension View {
    func conversationComposerSheetsModifier(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifierWrap(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

extension View {
    func conversationComposerSheetsModifierInit(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        modifier(ConversationComposerSheetsModifier(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        ))
    }
}

extension View {
    func conversationComposerSheetsModifierWrap(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifierInit(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentModifiers<Content: View>(on content: Content) -> some View {
        attachmentImporters(on: attachmentSheets(on: content))
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentImporters<Content: View>(on content: Content) -> some View {
        content
            .conversationCameraCover(model: model, showCamera: $showCamera)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.pdf, .text, .sourceCode, .json, .commaSeparatedText]) { result in
                if case .success(let url) = result { model.addFile(url: url) }
            }
            .onChange(of: pickedPhoto) {
                handlePickedPhotoChange()
            }
    }
}

extension ConversationComposerSheetsModifier {
    func handlePickedPhotoChange() {
        guard let item = pickedPhoto else { return }
        pickedPhoto = nil
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                model.toast = "Não consegui ler a foto"; return
            }
            let mime = item.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
            model.addImage(data: data, suggestedName: nil, mimeType: mime,
                           identity: item.itemIdentifier ?? UUID().uuidString)
        }
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentPickerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showAttachmentSheet) {
                ComposerAttachmentsSheet(
                    pickedPhoto: $pickedPhoto,
                    onChooseFile: { showFileImporter = true },
                    onChooseCamera: { showCamera = true },
                    onPaste: { model.addClipboard(text: $0) }
                )
            }
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentSheets<Content: View>(on content: Content) -> some View {
        workspacePickerSheet(on:
            attachmentPickerSheet(on: content)
        )
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func workspacePickerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showWorkspaceSheet) {
                WorkspaceSheet(workspaces: session.workspaces, current: model.workspaceName) { ws in
                    model.workspaceSlug = ws.id
                    model.workspaceName = ws.name
                    model.workspacePath = session.workspaceFullPath(forKey: ws.id)
                }
            }
    }
}

extension View {
    func conversationCameraCover(model: ConversationModel, showCamera: Binding<Bool>) -> some View {
        modifier(ConversationCameraCoverModifier(model: model, showCamera: showCamera))
    }
}

extension ConversationCameraCoverModifier {
    func cameraCoverA11y<Content: View>(_ content: Content) -> some View {
        content
            .ignoresSafeArea()
            .accessibilityIdentifier(A11yID.cameraPicker)
            .accessibilityLabel(CameraPickerA11y.spokenSurface)
            .accessibilityHint(CameraPickerA11y.spokenHint)
            .transaction { txn in
                if reduceMotion { txn.disablesAnimations = true }
            }
    }
}

extension ConversationCameraCoverModifier {
    func cameraCoverOnCapture(data: Data) {
        model.addImage(
            data: data,
            suggestedName: nil,
            mimeType: "image/jpeg",
            identity: UUID().uuidString,
            source: "camera"
        )
    }
}

extension ConversationCameraCoverModifier {
    func cameraCoverOnCaptureFailed() {
        model.toast = CameraPickerA11y.captureFailedToast
    }
}

extension ConversationCameraCoverModifier {
    var cameraCoverContent: some View {
        cameraCoverA11y(
            CameraPicker(
                onCapture: { cameraCoverOnCapture(data: $0) },
                onCaptureFailed: cameraCoverOnCaptureFailed,
                onCancel: {}
            )
        )
    }
}

struct ConversationCameraCoverModifier: ViewModifier {
    var model: ConversationModel
    @Binding var showCamera: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showCamera) {
                cameraCoverContent
            }
    }
}

struct ConversationComposerSheetsModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var model: ConversationModel
    var session: AtlasSession
    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var showCamera: Bool
    @Binding var showFileImporter: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    let onSteerSubmit: (TraceID, String, AtlasInteractionSteerScope) -> Void

    func body(content: Content) -> some View {
        modifierChain(on: content)
    }
}

extension ConversationComposerSheetsModifier {
    func modifierChain(on content: Content) -> some View {
        handoffAndQueueObservers(on:
            attachmentModifiers(on:
                reviewSteerQueueSheets(on:
                    modeEffortSheets(on: content)
                )
            )
        )
    }
}

extension ConversationComposerSheetsModifier {
    func modeEffortSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
            .sheet(isPresented: $showEffortSheet) { EffortSheet(model: model) }
    }
}

extension ConversationComposerSheetsModifier {
    func handoffAndQueueObservers<Content: View>(on content: Content) -> some View {
        content
            .onChange(of: model.queuedMessages.isEmpty) { _, empty in
                if empty { showQueueSheet = false }
            }
            .onChange(of: model.latestSurfaceHandoff?.id) {
                guard let h = model.latestSurfaceHandoff, h.status == "ready" else { return }
                let destino = atlasSurfaceLabel(h.toSurface)
                model.toast = "Pronto no \(destino) — mesma conversa, mesma sessão."
                AtlasMotion.successNotification(reduceMotion: reduceMotion)
            }
    }
}

extension ConversationComposerSheetsModifier {
    func changeReviewSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $reviewTrace) { ref in
                ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $artifactTrace) { ref in
                ArtifactSheet(reviews: model.reviews, traceId: ref.id)
            }
    }
}

extension ConversationComposerSheetsModifier {
    func queueSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showQueueSheet) {
                QueuedFollowUpsSheet(model: model)
            }
    }
}

extension ConversationComposerSheetsModifier {
    func reviewSteerQueueSheets<Content: View>(on content: Content) -> some View {
        steerSheet(on: queueSheet(on: changeReviewSheets(on: content)))
    }
}

extension ConversationComposerSheetsModifier {
    func steerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $steerTrace) { ref in
                SteerInteractionSheet(
                    traceId: ref.id,
                    model: model
                ) { instruction, scope in
                    onSteerSubmit(ref.id, instruction, scope)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func conversationComposerSheetsModifierForward(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifier(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

struct ConversationReviewTraceRef: Identifiable { let id: TraceID }
struct ConversationSteerTraceRef: Identifiable { let id: TraceID }


// Cycle 043 fuse → SteerInteractionSheet.swift

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

extension SteerInteractionSheet {
    var formHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Redirecionar")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("A instrução entra no próximo checkpoint seguro desta execução. O Atlas pode recusar e devolver o motivo público.")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            formScopePicker
        }
    }
}

// Recibo só de model.lastSteerReceipt; silêncio total sem recibo correspondente.

extension SteerInteractionSheet {
    func spokenReceiptLabel(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "último recibo, instrução enfileirada para o próximo checkpoint seguro"
        }
        let reason = receipt.reason?.rawValue ?? "motivo_indisponivel"
        return "último recibo, steering rejeitado, motivo \(reason)"
    }
}

extension SteerInteractionSheet {
    func spokenScopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "escopo passo atual"
        case .replan: return "escopo replanejamento"
        }
    }
}

extension SteerInteractionSheet {
    func spokenSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "enviar instrução de redirecionamento" : "enviar indisponível, instrução vazia"
    }
}

extension SteerInteractionSheet {
    func spokenSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }
}

extension SteerInteractionSheet {
    func steerA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.steerSheet)
            // Contain without fused sheet label so scope/field/submit stay focusable.
            .accessibilityElement(children: .contain)
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
    var formScopePicker: some View {
        Picker("Escopo", selection: $scope) {
            ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .frame(minHeight: 48) // HIG interactive minimum
        .onChange(of: scope) { _, _ in
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        }
        .accessibilityIdentifier(A11yID.steerScope)
        .accessibilityLabel(spokenScopeLabel(scope))
        .accessibilityHint("Define se a instrução vale o passo atual ou um replanejamento")
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
            .font(AtlasFont.serif(15))
            .foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent)
            .lineLimit(3...7)
            .padding(12)
            .frame(minHeight: 88, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface))
            // Soft gold-quiet steer field — match composer/search inputs.
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.goldBorder.opacity(0.45), lineWidth: 1))
            // Soft field lift — same plane as search glass / primary inputs.
            .atlasElevation(radius: 6, y: 2, opacity: 0.1)
            .accessibilityIdentifier(A11yID.steerInstruction)
            .accessibilityHint("Descreve o que deve mudar na execução")
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
    var canSubmit: Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var matchedReceipt: AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
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
        Button("Enviar") {
            // Medium: primary governed redirect (same class as composer send).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onSubmit(instruction, scope)
        }
        .disabled(!canSubmit)
        .accessibilityIdentifier(A11yID.steerSubmit)
        .accessibilityLabel(spokenSubmitLabel(canSubmit: canSubmit))
        .accessibilityHint(spokenSubmitHint(canSubmit: canSubmit))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(canSubmit ? 9 : 0)
    }
}

extension SteerInteractionSheet {
    func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> some View {
        let text = receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"

        return Text(text)
            .font(AtlasFont.mono(11))
            .foregroundStyle(receipt.isAccepted ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface.opacity(0.65)))
            // Soft gold-quiet steer receipt chip.
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
            // Receipt chip floats above the form surface after steer.
            .atlasElevation(radius: 6, y: 2, opacity: 0.1)
    }
}


// Cycle 043 fuse → QueuedFollowUpsSheet.swift

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss

    var model: ConversationModel

    var body: some View {
        queueSheetA11yShell(queueSheetBodyBranch)
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
    func queueOrderCaption(total: Int) -> some View {
        if total > 1 {
            Text("Ordem da fila · a cabeça envia quando o turno terminar")
                .atlasSans(12)
                // Soft gold-quiet queue order caption.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
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
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            // Contain without fused sheet label so queue rows stay focusable.
            .accessibilityElement(children: .contain)
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
    func sheetTitle(count: Int) -> String {
        count == 1 ? "Fila · 1" : "Fila · \(count)"
    }
}


// Cycle 043 fuse → QueuedFollowUpRow.swift

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
            // Medium: promote commits the next instruction (send class).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onPromote()
        } label: {
            Image(systemName: "arrow.up")
                .atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 48, height: 48)
                .background(Circle().fill(AtlasTheme.goldVeil)
                    .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                // Match scroll FAB / recovery chrome — send-class promote floats.
                .atlasElevation(radius: 8, y: 2, opacity: 0.16)
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(promoteLabel)
        .accessibilityHint(promoteHint)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // promote is send-class
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
        .frame(minHeight: 56, alignment: .center)
        .contentShape(Rectangle())
        .accessibilityIdentifier(A11yID.queueRow(index))
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    AtlasTheme.accent.opacity(0),
                    AtlasTheme.accent.opacity(0.18),
                    AtlasTheme.separator,
                    AtlasTheme.accent.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.leading, 24)
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
                // Soft gold-quiet queue remove — secondary chrome, not coral.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .frame(width: 48, height: 48)
                .background(Circle().fill(AtlasTheme.surfaceHi))
                .overlay(Circle().stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
                .atlasElevation(radius: 6, y: 2, opacity: 0.14)
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(removeLabel)
        .accessibilityHint(removeHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.queueRemove(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowMessagePreview: some View {
        Text(message.text)
            .font(AtlasFont.serif(15))
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
                .font(AtlasFont.mono(10, .medium))
                // Soft gold-quiet queue position; head stays full accent.
                .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.55))
                .padding(.horizontal, index == 0 ? 8 : 0)
                .padding(.vertical, index == 0 ? 3 : 0)
                .background {
                    if index == 0 {
                        Capsule().fill(AtlasTheme.goldVeil)
                    }
                }
                .overlay {
                    if index == 0 {
                        Capsule().stroke(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1)
                    }
                }
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


// Cycle 045 fuse → ExecutingStrip.swift

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            stripActionButtons
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(AtlasTheme.surface.opacity(0.45))
                .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.35), lineWidth: 1))
        )
        .atlasElevation(radius: 8, y: 2, opacity: 0.12)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(stripAccessibilityLabel)
    }
}

extension ExecutingStrip {
    var stripAccessibilityLabel: String {
        var parts: [String] = []
        if bubble.showsReconnectSurface {
            parts.append(bubble.reconnectSpokenLabel)
        } else if let p = bubble.executionProgress {
            parts.append("Execução ao vivo, passo \(p.current) de \(p.total), \(p.title)")
        } else if let act = bubble.currentActivity {
            parts.append("Execução ao vivo, \(act.title)")
        } else {
            parts.append("Seguindo a execução")
        }
        parts.append(contentsOf: stripAccessibilityExtras())
        return parts.joined(separator: ", ")
    }
}

extension ExecutingStrip {
    func stripAccessibilityExtras() -> [String] {
        var parts: [String] = []
        let events = bubble.activities.count
        parts.append("\(events) evento\(events == 1 ? "" : "s")")
        if let started = bubble.startedAt {
            let secs = max(0, Int(Date().timeIntervalSince(started)))
            parts.append("\(secs) segundos decorridos")
        }
        if let stats = bubble.diffStats {
            parts.append("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
        return parts
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripActionButtons: some View {
        steerActionButton
        Button {
            // Medium: interrupts live execution (control commit class).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onStop()
        } label: {
            Text("Parar")
                .font(AtlasFont.serif(13, .medium))
                .foregroundStyle(AtlasTheme.domOperacional)
                .padding(.horizontal, 10)
                .lineLimit(1)
                .frame(minHeight: 48)
                .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
                .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("Parar execução")
        .accessibilityHint("Interrompe a execução ao vivo")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(9)
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var steerActionButton: some View {
        if let onSteer {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onSteer()
            } label: {
                Text("Redirecionar")
                    .font(AtlasFont.serif(13, .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 10)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(minHeight: 48)
                    .background(Capsule().fill(AtlasTheme.goldVeil))
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.7), lineWidth: 1))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("Redirecionar execução")
            .accessibilityHint("Abre opções para redirecionar a execução ao vivo")
            .accessibilityAddTraits(.isButton)
        }
    }
}


// Cycle 044 fuse → AtlasMarkdownView.swift

extension AtlasMarkdownView {
    func refreshBlocks(force: Bool) {
        let count = text.count
        if count == cachedCount, !force { return }

        if !force, streaming {
            let now = CFAbsoluteTimeGetCurrent()
            let elapsed = now - lastParseAt
            if elapsed < 0.1, !Self.isBlockBoundary(text) { return }
            lastParseAt = now
        } else {
            lastParseAt = CFAbsoluteTimeGetCurrent()
        }

        cachedCount = count
        blocks = AtlasMarkdown.parse(text)
    }
}

extension AtlasMarkdownView {
    /// Fronteira barata: parágrafo novo ou fence fechando — re-parse imediato.
    static func isBlockBoundary(_ text: String) -> Bool {
        text.hasSuffix("\n\n") || text.hasSuffix("```\n") || text.hasSuffix("```")
    }
}

extension AtlasMarkdownView {
    func parseRefreshLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { refreshBlocks(force: true) }
            .onChange(of: text) { _, _ in refreshBlocks(force: !streaming) }
            .onChange(of: streaming) { _, isStreaming in
                if !isStreaming { refreshBlocks(force: true) }
            }
    }
}

extension AtlasMarkdownView {
    struct InlineBase {
        let font: Font
        let size: CGFloat
        let color: Color
        // Serif/mono escalam sozinhos (relativeTo); o sans dos marks precisa
        // da categoria para escalar junto.
        var typeSize: DynamicTypeSize = .large
    }

    @ViewBuilder
    func heading(_ level: Int, _ spans: [InlineSpan]) -> some View {
        switch level {
        case 1: headingOne(spans)
        case 2: headingTwo(spans)
        default: headingDefault(spans)
        }
    }
}

// Renderiza markdown na tipografia do Atlas — porte de EditorialMarkdown.tsx.
struct AtlasMarkdownView: View {
    let text: String
    var streaming: Bool = false

    // O corpo da resposta escala com o ajuste de texto do operador; os marks
    // derivados (bold/link) seguem pela InlineBase.typeSize.
    @Environment(\.dynamicTypeSize) var typeSize

    @State var blocks: [MarkdownBlock] = []
    @State var cachedCount: Int = -1
    @State var lastParseAt: CFAbsoluteTime = 0

    var body: some View {
        parseRefreshLifecycle(
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                    blockView(block, index: index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockView(_ block: MarkdownBlock, index: Int) -> some View {
        blockViewBody(block, index: index)
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewBody(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .paragraph, .heading:
            blockViewInline(block)
        case .list, .quote, .code, .divider, .table:
            blockViewStructural(block, index: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewInline(_ block: MarkdownBlock) -> some View {
        switch block {
        case .paragraph(let spans):
            Text(inline(spans, base: .init(font: AtlasFont.sans(16, weight: .regular, at: typeSize), size: 16, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(6)
        case .heading(let level, let spans):
            heading(level, spans)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewCodeBlock(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code(let codeText, let lang) = block {
            CodeBlockView(code: codeText, lang: lang, blockIndex: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCode(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code = block {
            blockViewCodeBlock(block, index: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCodeTable(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .code:
            blockViewStructuralCode(block, index: index)
        case .divider:
            blockViewDividerBlock
        case .table:
            blockViewTableBlock(block)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    var blockViewDividerBlock: some View {
        // Soft gold-breath between editorial blocks.
        Rectangle().fill(AtlasTheme.accent.opacity(0.18)).frame(height: 1).padding(.vertical, 2)
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewListBlock(_ block: MarkdownBlock) -> some View {
        if case .list(let ordered, let items) = block {
            listBlock(ordered: ordered, items: items)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralListQuote(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list:
            blockViewListBlock(block)
        case .quote:
            blockViewQuoteBlock(block)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewQuoteBlock(_ block: MarkdownBlock) -> some View {
        if case .quote(let spans) = block {
            quoteBlock(spans)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewTableBlock(_ block: MarkdownBlock) -> some View {
        if case .table(let headers, let rows) = block {
            tableView(headers, rows)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructural(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list, .quote:
            blockViewStructuralListQuote(block, index: index)
        case .code, .divider, .table:
            blockViewStructuralCodeTable(block, index: index)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlock(ordered: Bool, items: [[InlineSpan]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                listBlockItem(ordered: ordered, index: idx, item: item)
            }
        }
    }
}

extension AtlasMarkdownView {
    func headingDefault(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.sans(14, weight: .semibold, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 2)
    }
}

extension AtlasMarkdownView {
    func headingOne(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.serif(22, .semibold), size: 22, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 4)
    }
}

extension AtlasMarkdownView {
    func headingTwo(_ spans: [InlineSpan]) -> some View {
        Text(plain(spans))
            .atlasSans(11, .medium).tracking(0.2)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityAddTraits(.isHeader)
            .padding(.top, 6).padding(.bottom, 2)
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func quoteBlock(_ spans: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                .shadow(color: AtlasTheme.accent.opacity(0.35), radius: 3, y: 0)
                .accessibilityHidden(true)
            Text(inline(spans, base: .init(font: AtlasFont.serifItalic(17), size: 17, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenQuote(plain(spans)))
    }
}

extension CodeBlockView {
    var codeBlockBackground: some View {
        RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface)
            // Soft gold-quiet code block chrome.
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
            .atlasElevation(radius: 6, y: 2, opacity: 0.1)
    }
}

extension CodeBlockView {
    var lineCount: Int {
        guard !code.isEmpty else { return 0 }
        return code.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    var canCopy: Bool { !code.isEmpty }
}

extension CodeBlockView {
    var copyButtonTitle: String {
        guard canCopy else { return "Copiar" }
        return copied ? "Copiado" : "Copiar"
    }

    var copyForeground: Color {
        // Soft gold-quiet disabled/ready copy ladder.
        guard canCopy else { return AtlasTheme.accent.opacity(0.32) }
        return copied ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.72)
    }
}

extension CodeBlockView {
    func copyCode() {
        guard canCopy else { return }
        UIPasteboard.general.string = code
        guard UIPasteboard.general.string == code else { return }
        // Success class: copy confirmed on pasteboard.
        AtlasMotion.successNotification(reduceMotion: reduceMotion)
        setCopied(true)
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            setCopied(false)
        }
    }

    func setCopied(_ value: Bool) {
        if reduceMotion { copied = value }
        else { withAnimation(AtlasMotion.editorial) { copied = value } }
    }
}

extension CodeBlockView {
    @ViewBuilder
    var codeBlockShellFrame: some View {
        codeBlockShellStack
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(codeBlockBackground)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.markdownCodeBlock(blockIndex))
    }
}

extension CodeBlockView {
    @ViewBuilder
    var codeBlockShellStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            codeBlockToolbar
            codeBlockScroll
        }
    }
}

extension CodeBlockView {
    var codeBlockShell: some View {
        codeBlockShellFrame
    }
}

extension CodeBlockView {
    var codeBlockToolbar: some View {
        HStack {
            if let langLabel = MarkdownCodeBlockA11y.langLabel(lang: lang) {
                Text(langLabel)
                    .font(AtlasFont.mono(10, .medium))
                    .tracking(0.3)
                    .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AtlasTheme.goldVeil.opacity(0.55)))
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1))
                    .accessibilityHidden(true)
            }
            Spacer()
            codeBlockCopyButton
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)
    }
}

extension CodeBlockView {
    @ViewBuilder
    var codeBlockCopyButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            copyCode()
        } label: {
            Text(copyButtonTitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(copyForeground)
                .padding(.horizontal, 12)
                .frame(minHeight: 48)
                .background(
                    Capsule().fill(
                        canCopy
                            ? (copied ? AtlasTheme.goldVeil : AtlasTheme.surface.opacity(0.55))
                            : AtlasTheme.surface.opacity(0.25)
                    )
                )
                .overlay(
                    Capsule().stroke(
                        canCopy
                            // Soft gold-quiet ready; full goldBorder when copied.
                            ? (copied ? AtlasTheme.goldBorder : AtlasTheme.goldBorder.opacity(0.45))
                            : AtlasTheme.goldBorder.opacity(0.22),
                        lineWidth: 1
                    )
                )
                .atlasElevation(radius: 4, y: 1, opacity: canCopy ? (copied ? 0.12 : 0.08) : 0.04)
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .disabled(!canCopy)
        .accessibilityLabel(MarkdownCodeBlockA11y.spokenCopyButton(copied: copied, canCopy: canCopy))
        .accessibilityHint(MarkdownCodeBlockA11y.copyHint(canCopy: canCopy))
        .accessibilityIdentifier(A11yID.markdownCodeCopy(blockIndex))
        .accessibilityAddTraits(.isButton)
    }
}

// Code block "carved in slate" com label de linguagem + botão copiar (gap do RN).

struct CodeBlockView: View {
    let code: String
    let lang: String?
    var blockIndex: Int = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var copied = false

    var body: some View {
        codeBlockShell
    }
}

extension CodeBlockView {
    var codeBlockScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                .lineSpacing(5).textSelection(.enabled)
                .padding(.horizontal, 16).padding(.bottom, 14)
                .accessibilityLabel(MarkdownCodeBlockA11y.spokenBlock(lang: lang, lineCount: lineCount))
        }
    }
}

/// Marcadores tipográficos são decorativos; VoiceOver lê só o conteúdo.

enum MarkdownBlocksA11y {
    static func spokenListItem(ordered: Bool, index: Int, plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ordered ? "item \(index + 1), vazio" : "item, vazio"
        }
        return ordered ? "item \(index + 1), \(trimmed)" : trimmed
    }

    static func spokenQuote(_ plain: String) -> String {
        MarkdownBlocksA11yQuote.spokenQuote(plain)
    }
}

enum MarkdownBlocksA11yQuote {
    static func spokenQuote(_ plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "citação vazia" : "citação, \(trimmed)"
    }
}

enum MarkdownCodeBlockA11y {
    static func spokenBlock(lang: String?, lineCount: Int) -> String {
        var parts = ["bloco de código"]
        if let lang, !lang.isEmpty {
            parts.append("linguagem \(lang.lowercased())")
        } else {
            parts.append("linguagem não informada")
        }
        if lineCount == 0 {
            parts.append("vazio")
        } else {
            parts.append("\(lineCount) linha\(lineCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }
}

extension MarkdownCodeBlockA11y {
    static func spokenCopyButton(copied: Bool, canCopy: Bool) -> String {
        if !canCopy { return "copiar indisponível, bloco vazio" }
        return copied ? "código copiado" : "copiar código"
    }

    static func copyHint(canCopy: Bool) -> String {
        canCopy ? "cola este bloco na área de transferência" : ""
    }

    static func langLabel(lang: String?) -> String? {
        guard let lang, !lang.isEmpty else { return nil }
        return lang.lowercased()
    }
}

extension AtlasMarkdownView {
    func plain(_ spans: [InlineSpan]) -> String {
        spans.map {
            switch $0 {
            case .text(let t), .bold(let t), .italic(let t), .code(let t): return t
            case .link(let t, _): return t
            }
        }.joined()
    }
}

extension AtlasMarkdownView {
    func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            out.append(inlineMark(span, base: base))
        }
        return out
    }
}

extension AtlasMarkdownView {
    func inlineMarkTextFallback(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        switch span {
        case .text(let t):
            return inlineTextMark(t, base: base)
        default:
            return AttributedString()
        }
    }
}

extension AtlasMarkdownView {
    func inlineTextMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = base.font
        piece.foregroundColor = base.color
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineMark(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        if let decorated = inlineDecoratedMark(span, base: base) {
            return decorated
        }
        if let emphasis = inlineEmphasisMark(span, base: base) {
            return emphasis
        }
        return inlineMarkTextFallback(span, base: base)
    }
}

extension AtlasMarkdownView {
    func inlineCodeMark(_ text: String) -> AttributedString {
        var piece = AttributedString(" \(text) ")
        piece.font = AtlasFont.mono(13)
        piece.foregroundColor = AtlasTheme.textPrimary
        piece.backgroundColor = AtlasTheme.surface
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineLinkMark(_ text: String, url: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .medium, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.prussian
        piece.underlineStyle = .single
        if let u = URL(string: url) { piece.link = u }
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineDecoratedMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
        case .code(let t):
            return inlineCodeMark(t)
        case .link(let t, let url):
            return inlineLinkMark(t, url: url, base: base)
        default:
            return nil
        }
    }
}

extension AtlasMarkdownView {
    func inlineBoldMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .semibold, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.textPrimary
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineItalicMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.serifItalic(base.size)
        piece.foregroundColor = base.color
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineEmphasisMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
        case .bold(let t):
            return inlineBoldMark(t, base: base)
        case .italic(let t):
            return inlineItalicMark(t, base: base)
        default:
            return nil
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlockItem(ordered: Bool, index: Int, item: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            listItemMarker(ordered: ordered, index: index)
            Text(inline(item, base: .init(font: AtlasFont.sans(16, weight: .regular, at: typeSize), size: 16, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenListItem(ordered: ordered, index: index, plain: plain(item)))
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func listItemMarker(ordered: Bool, index: Int) -> some View {
        if ordered {
            Text("\(index + 1).")
                // Soft gold-quiet ordered list markers.
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.accent.opacity(0.65))
                .frame(width: 26, alignment: .leading).padding(.top, 3)
                .accessibilityHidden(true)
        } else {
            Text("—")
                .atlasSans(16).foregroundStyle(AtlasTheme.accent)
                .frame(width: 22, alignment: .leading)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func tableDataRows(_ rows: [[[InlineSpan]]], colCount: Int) -> some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
            HStack(spacing: 0) {
                ForEach(0..<colCount, id: \.self) { ci in
                    Text(inline(ci < row.count ? row[ci] : [], base: .init(font: AtlasFont.sans(14, weight: .regular, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
                }
            }
            .padding(.vertical, 12)
            // Soft gold-breath row rule.
            .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.accent.opacity(0.14)).frame(height: 1) }
        }
    }
}

extension AtlasMarkdownView {
    func tableView(_ headers: [[InlineSpan]], _ rows: [[[InlineSpan]]]) -> some View {
        let colCount = max(headers.count, rows.map { $0.count }.max() ?? 0)
        return VStack(spacing: 0) {
            tableHeaderRow(headers, colCount: colCount)
            tableDataRows(rows, colCount: colCount)
        }
        .background(AtlasTheme.surface.opacity(0.35), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft))
        // Soft gold-quiet table chrome.
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.goldBorder.opacity(0.4), lineWidth: 1))
        .atlasElevation(radius: 4, y: 1, opacity: 0.08)
    }
}

extension AtlasMarkdownView {
    func tableHeaderRow(_ headers: [[InlineSpan]], colCount: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<colCount, id: \.self) { ci in
                Text(plain(ci < headers.count ? headers[ci] : []))
                    .font(AtlasFont.mono(10, .medium)).tracking(0.3)
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 10)
        .background(AtlasTheme.bgRecessed.opacity(0.55))
        // Soft gold-breath under table header.
        .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.accent.opacity(0.28)).frame(height: 1) }
    }
}


// Cycle 044 fuse → ArtifactSheet.swift

enum ArtifactPreviewState {
    case idle
    case loading
    case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
    case tooLarge(Int)
    case failed(String)
}

struct ArtifactSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var selectedID: String?
    @State var preview: ArtifactPreviewState = .idle
    @State var loadFinished = false
    @State var mountRevealed = 0

    var body: some View {
        artifactSheetLifecycle(artifactNavigationShell)
    }
}

extension ArtifactSheet {
    var artifactNavigationShell: some View {
        NavigationStack {
            artifactSheetChrome(
                ZStack {
                    AtlasTheme.bg.ignoresSafeArea()
                    content
                }
            )
        }
    }
}

extension ArtifactSheet {
    func artifactSheetA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.artifactsSheet)
            // Contain without fused sheet label so list/preview stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension ArtifactSheet {
    func artifactSheetToolbar<Content: View>(_ content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar artefatos",
                        spokenHint: "volta para a conversa",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Artefatos")
                            .font(AtlasFont.serif(17, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        LinearGradient(
                            colors: [
                                AtlasTheme.accent.opacity(0),
                                AtlasTheme.accent.opacity(0.5),
                                AtlasTheme.accent.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 48, height: 1.5)
                        .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Artefatos")
                }
            }
            .overlay(alignment: .top) { toast }
    }
}

extension ArtifactSheet {
    func artifactSheetChrome<Content: View>(_ content: Content) -> some View {
        artifactSheetA11y(artifactSheetToolbar(content))
    }
}

extension ArtifactSheet {
    func artifactSheetInitialTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
        if hasDeliveryProof { await runMountAnimation() }
        else { mountRevealed = deliveryChecks.count }
    }
}

extension ArtifactSheet {
    func artifactSheetPreviewTask(for item: AtlasTraceArtifacts.Item?) async {
        guard mountComplete, let item else { return }
        await load(item)
    }
}

extension ArtifactSheet {
    func artifactSheetSyncSelection(ids: [String]) {
        if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
            selectedID = ids.first
        }
    }
}

extension ArtifactSheet {
    func artifactSheetLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .task { await artifactSheetInitialTask() }
            .onChange(of: items.map(\.id)) { _, ids in artifactSheetSyncSelection(ids: ids) }
            .task(id: selected?.id) { await artifactSheetPreviewTask(for: selected) }
    }
}

extension ArtifactSheet {
    var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return artifacts?.items ?? []
    }
    var selected: AtlasTraceArtifacts.Item? {
        items.first { $0.id == selectedID } ?? items.first
    }
}

extension ArtifactSheet {
    @ViewBuilder var toast: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                // Match conversation toast elevation — floating review feedback shares one plane.
                .atlasElevation(radius: 10, y: 3, opacity: 0.2)
                .padding(.top, 8)
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityAddTraits(.isStaticText)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    if reduceMotion { reviews.toast = nil }
                    else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
                }
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var content: some View {
        if showsEmptyOrUnavailable {
            emptyOrUnavailable
        } else if hasDeliveryProof, !mountComplete {
            artifactMount
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
        } else {
            loadedArtifactsBody
        }
    }
}

extension ArtifactSheet {
    var loadedArtifactsHeader: some View {
        Text("Artefatos do turno · \(artifacts?.workspaceLabel ?? "workspace")")
            .font(AtlasFont.mono(10)).tracking(0.4)
            // Soft gold-quiet artifacts section kicker.
            .foregroundStyle(AtlasTheme.accent.opacity(0.68))
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 14)
    }
}

extension ArtifactSheet {
    var loadedArtifactsScroll: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                artifactList
                previewPane
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

extension ArtifactSheet {
    var loadedArtifactsBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            loadedArtifactsHeader
            loadedArtifactsScroll
        }
    }
}

extension ArtifactSheet {
    var artifactList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                artifactListRow(index: index, item: item)
                if index < items.count - 1 {
                    Divider().overlay(AtlasTheme.separatorSoft)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal, 12)
        .atlasCard()
        .atlasElevation(radius: 8, y: 2, opacity: 0.12)
        // Contain without fused label: each file row stays a button.
        .accessibilityElement(children: .contain)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRow(index: Int, item: AtlasTraceArtifacts.Item) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selectedID = item.id
        } label: {
            artifactListRowLabel(item: item)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.artifactsItem(index))
        .accessibilityLabel("\(item.name), \(ArtifactViewer.byteLabel(item.byteSize)), \(ArtifactViewer.kindLabel(item.kind))")
        .accessibilityAddTraits(item.id == selected?.id ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(item.id == selected?.id ? "Selecionado no preview" : "Abre o preview deste artefato")
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRowLeading(item: AtlasTraceArtifacts.Item) -> some View {
        Text("▸")
            .font(AtlasFont.mono(11))
            // Soft gold-quiet list caret; selected stays full accent.
            .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
        // Linha de lista fala em sans (canon §C: serif é masthead/título).
        Text(item.name)
            .atlasSans(15, .medium)
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

extension ArtifactSheet {
    func artifactListRowLabel(item: AtlasTraceArtifacts.Item) -> some View {
        HStack(spacing: 10) {
            artifactListRowLeading(item: item)
            Spacer()
            artifactListRowMeta(item: item)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(minHeight: 48)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                .fill(item.id == selected?.id ? AtlasTheme.goldVeil : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                .stroke(item.id == selected?.id ? AtlasTheme.goldBorder : Color.clear, lineWidth: 1)
        )
    }
}

extension ArtifactSheet {
    func artifactListRowMeta(item: AtlasTraceArtifacts.Item) -> some View {
        Text("\(ArtifactViewer.byteLabel(item.byteSize))  \(ArtifactViewer.kindLabel(item.kind))")
            .font(AtlasFont.mono(10))
            // Soft gold-quiet artifact size/kind meta.
            .foregroundStyle(AtlasTheme.accent.opacity(0.58))
            .accessibilityHidden(true)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var emptyOrUnavailable: some View {
        if !loadFinished, artifacts == nil {
            TraceEvidenceLoading(text: "Consultando artefatos…", reduceMotion: reduceMotion)
        } else if loadFinished, artifacts == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar artefatos.",
                subtitle: "Feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.artifactsLoadFailure,
                spoken: "Não foi possível consultar artefatos"
            )
        } else {
            artifactsUnavailable
        }
    }
}

extension ArtifactSheet {
    var showsEmptyOrUnavailable: Bool {
        (!loadFinished && artifacts == nil)
            || (loadFinished && artifacts == nil)
            || artifacts?.state == .unavailable
            || items.isEmpty
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var emptyVisualizable: some View {
        Text("Nenhum artefato visualizável")
            .font(AtlasFont.serifItalic(15))
            // Soft gold-quiet empty artifacts honesty.
            .foregroundStyle(AtlasTheme.accent.opacity(0.58))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.artifactsEmpty)
            .accessibilityLabel("Sem artefatos visualizáveis nesta execução")
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var artifactsUnavailable: some View {
        if artifacts?.state == .unavailable {
            TraceEvidenceUnavailable(
                title: "Sem artefatos nesta execução.",
                subtitle: TraceEvidenceCopy.unavailableReason(artifacts?.reason),
                identifier: A11yID.artifactsUnavailable,
                spoken: TraceEvidenceCopy.unavailableSpoken(
                    prefix: "Sem artefatos nesta execução",
                    reason: artifacts?.reason
                )
            )
        } else if items.isEmpty {
            emptyVisualizable
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            previewPaneStates
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
        .atlasElevation(radius: 8, y: 2, opacity: 0.12)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func previewPaneFailure(bytes: Int? = nil, message: String? = nil) -> some View {
        if let bytes {
            previewTooLarge(bytes: bytes)
        } else if let message {
            previewMessageFailure(message)
        }
    }
}

extension ArtifactSheet {
    func load(_ item: AtlasTraceArtifacts.Item) async {
        preview = .loading
        do {
            let content = try await reviews.loadArtifactContent(traceId: traceId, item: item)
            preview = .loaded(item, content)
        } catch let api as AtlasApiError where api.status == 413 {
            preview = .tooLarge(item.byteSize)
        } catch {
            preview = .failed(atlasUserMessage(for: error))
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func previewMessageFailure(_ message: String) -> some View {
        Text(message)
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.domOperacional)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("Preview falhou, \(message)")
    }
}

extension ArtifactSheet {
    var previewPaneLoading: some View {
        TraceEvidenceLoading(text: "Carregando preview…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, minHeight: 180)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneBusyOrFailed: some View {
        switch preview {
        case .idle, .loading:
            previewPaneLoading
        case .tooLarge(let bytes):
            previewPaneFailure(bytes: bytes)
        case .failed(let message):
            previewPaneFailure(message: message)
        default:
            EmptyView()
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneLoaded: some View {
        if case .loaded(let item, let content) = preview {
            ArtifactPreviewContent(item: item, content: content)
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneStates: some View {
        switch preview {
        case .idle, .loading, .tooLarge, .failed:
            previewPaneBusyOrFailed
        case .loaded:
            previewPaneLoaded
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func previewTooLarge(bytes: Int) -> some View {
        ArtifactFileFicha(
            name: selected?.name ?? "artefato",
            subtitle: "grande demais para visualizar aqui · \(ArtifactViewer.byteLabel(bytes))"
        )
        .accessibilityLabel(
            ArtifactViewerA11y.spokenTooLarge(
                name: selected?.name ?? "artefato",
                bytes: bytes
            )
        )
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func mountCheckRowTexts(check: ArtifactDeliveryCheck) -> some View {
        Text(check.label)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
        Spacer(minLength: 0)
        Text(check.status)
            .font(AtlasFont.mono(10))
            .foregroundStyle(check.isPassing ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }
}

extension ArtifactSheet {
    func mountCheckRow(index: Int, check: ArtifactDeliveryCheck) -> some View {
        HStack(spacing: 8) {
            mountCheckRowTexts(check: check)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(check.spoken)
        .accessibilityIdentifier(A11yID.artifactsMountCheck(index))
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var mountChecks: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(deliveryChecks.enumerated()), id: \.element.id) { index, check in
                if index < mountRevealed {
                    mountCheckRow(index: index, check: check)
                }
            }
        }
    }
}

extension ArtifactSheet {
    var mountCounterText: some View {
        HStack(spacing: 8) {
            Text("Montagem")
                .font(AtlasFont.mono(10)).tracking(0.4)
                // Soft gold-quiet mount kicker.
                .foregroundStyle(AtlasTheme.accent.opacity(0.68))
                .accessibilityHidden(true)
            Text("·")
                .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
                .accessibilityHidden(true)
            Text("\(min(mountRevealed, deliveryChecks.count))/\(deliveryChecks.count)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}

extension ArtifactSheet {
    var mountHeaderCounter: some View {
        HStack(spacing: 8) {
            mountCounterText
            if !mountComplete {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}

extension ArtifactSheet {
    func runMountAnimation() async {
        guard hasDeliveryProof else {
            mountRevealed = deliveryChecks.count
            return
        }
        if reduceMotion {
            mountRevealed = deliveryChecks.count
            return
        }
        mountRevealed = 0
        for step in 1...deliveryChecks.count {
            try? await Task.sleep(nanoseconds: 280_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(AtlasMotion.editorial) { mountRevealed = step }
        }
    }
}

extension ArtifactSheet {
    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}

// Montagem animada da entrega — só quando o contrato publica provas reais.

extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        artifactMountStack
    }
}

extension ArtifactSheet {
    var mountHeader: some View {
        mountHeaderCounter
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(mountSpoken)
    }
}

extension ArtifactSheet {
    var changeReview: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }
    var deliveryChecks: [ArtifactDeliveryCheck] { ArtifactDeliveryProof.checks(from: changeReview) }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }
}

extension ArtifactSheet {
    var artifactMountStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            mountHeader
            mountChecks
        }
        .padding(14)
        .atlasCard()
        .atlasElevation(radius: 8, y: 2, opacity: 0.12)
        .accessibilityIdentifier(A11yID.artifactsMount)
    }
}

extension ArtifactDeliveryCheck {
    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}

// Provas de montagem — só controles/testes reais do contrato C15 (nunca inventa 0/3).

struct ArtifactDeliveryCheck: Identifiable, Equatable {
    let id: String
    let label: String
    let status: String
}

enum ArtifactDeliveryProof {
    /// Controles + testRuns publicados na revisão trace-scoped — vazio = silêncio na montagem.
    static func checks(from review: AtlasTraceChangeReview?) -> [ArtifactDeliveryCheck] {
        guard review?.state == .available, let review else { return [] }
        let controls = review.controls.map {
            ArtifactDeliveryCheck(id: "control-\($0.id)", label: $0.slug, status: $0.status)
        }
        let tests = review.testRuns.map {
            ArtifactDeliveryCheck(id: "test-\($0.id)", label: $0.command ?? "teste", status: $0.status)
        }
        return controls + tests
    }
}


// Cycle 044 fuse → ArtifactViewer.swift

// Preview helpers do ArtifactSheet — fora do shell para a régua (~160).

enum ArtifactViewer {}

extension ArtifactViewer {
    static func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }
}

extension ArtifactViewer {
    static func kindLabelImageMarkdown(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        switch kind {
        case .image: return "imagem"
        case .markdown: return "markdown"
        default: return nil
        }
    }
}

extension ArtifactViewer {
    static func kindLabelDocument(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        if let imageMd = kindLabelImageMarkdown(kind) { return imageMd }
        switch kind {
        case .text: return "texto"
        case .diff: return "diff"
        default: return nil
        }
    }
}

extension ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        kindLabelDocument(kind) ?? "arquivo"
    }
}

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        Group { previewSwitch }
    }
}

extension ArtifactPreviewContent {
    var imageDecodeFailure: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "imagem não pôde ser decodificada · \(ArtifactViewer.byteLabel(item.byteSize))"
        )
        .accessibilityLabel(
            ArtifactViewerA11y.spokenDecodeFailure(name: item.name, bytes: item.byteSize)
        )
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var imagePreviewBranch: some View {
        if let image = UIImage(data: content.data) {
            ZoomableArtifactImage(image: image, name: item.name)
        } else {
            imageDecodeFailure
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var previewSwitch: some View {
        switch item.kind {
        case .image:
            imagePreviewBranch
        default:
            textishPreview
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var diffPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(String(decoding: content.data, as: UTF8.self))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 360)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArtifactViewerA11y.spokenPreview(item: item))
        .accessibilityHint("Arraste horizontalmente para ler o diff")
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishDocumentPreview: some View {
        switch item.kind {
        case .markdown, .text:
            textishMarkdownPreview(content.data)
        case .diff:
            diffPreview
        default:
            EmptyView()
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishFilePreview: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "\(ArtifactViewer.byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))"
        )
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    func textishMarkdownPreview(_ content: Data) -> some View {
        AtlasMarkdownView(text: String(decoding: content, as: UTF8.self), streaming: false)
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
        case .markdown, .text, .diff:
            textishDocumentPreview
        case .file:
            textishFilePreview
        default:
            EmptyView()
        }
    }
}

/// Sem inventar dimensões; sha só quando o contrato publica.

enum ArtifactViewerA11y {
    static func spokenFicha(name: String, subtitle: String) -> String {
        "\(name), \(subtitle)"
    }
}

extension ArtifactViewerA11y {
    static func spokenDecodeFailure(name: String, bytes: Int) -> String {
        "imagem \(name) não pôde ser decodificada, \(ArtifactViewer.byteLabel(bytes))"
    }
}

extension ArtifactViewerA11y {
    static func spokenPreviewImageMarkdown(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        switch item.kind {
        case .image:
            return "preview de imagem \(item.name), \(size)"
        case .markdown:
            return "preview markdown \(item.name), \(size)"
        default:
            return nil
        }
    }
}

extension ArtifactViewerA11y {
    static func spokenPreviewDocument(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        if let imageMd = spokenPreviewImageMarkdown(item: item, size: size) { return imageMd }
        switch item.kind {
        case .text:
            return "preview de texto \(item.name), \(size)"
        case .diff:
            return "preview de diff \(item.name), \(size)"
        default:
            return nil
        }
    }
}

extension ArtifactViewerA11y {
    static func spokenPreviewFile(item: AtlasTraceArtifacts.Item, kind: String, size: String) -> String {
        let sha = String(item.sha256.prefix(12))
        return "arquivo \(item.name), \(kind), \(size), sha \(sha)"
    }
}

extension ArtifactViewerA11y {
    static func spokenPreview(item: AtlasTraceArtifacts.Item) -> String {
        let kind = ArtifactViewer.kindLabel(item.kind)
        let size = ArtifactViewer.byteLabel(item.byteSize)
        return spokenPreviewDocument(item: item, size: size)
            ?? spokenPreviewFile(item: item, kind: kind, size: size)
    }
}

extension ArtifactViewerA11y {
    static func spokenTooLarge(name: String, bytes: Int) -> String {
        "\(name), grande demais para visualizar aqui, \(ArtifactViewer.byteLabel(bytes))"
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableIconTitle: some View {
        Image(systemName: systemImage)
            .atlasSans(22)
            // Soft gold-quiet empty bloom — same family as failure ✦ disks.
            .foregroundStyle(AtlasTheme.accent.opacity(0.72))
            .frame(width: 56, height: 56)
            .background(Circle().fill(AtlasTheme.surface.opacity(0.7)))
            .overlay(Circle().stroke(AtlasTheme.goldBorder.opacity(0.45), lineWidth: 1))
            .atlasElevation(radius: 8, y: 2, opacity: 0.12)
            .accessibilityHidden(true)
        Text(title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .multilineTextAlignment(.center)
            .accessibilityHidden(true)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableSubtitle: some View {
        if let subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        }
    }
}

extension TraceEvidenceUnavailable {
    var unavailableStack: some View {
        VStack(spacing: 12) {
            unavailableIconTitle
            unavailableSubtitle
        }
    }
}

extension TraceEvidenceCopy {
    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "Sem workspace ligado a esta execução"
        case "no_run": return "Nenhum run de engenharia vinculado"
        default: return nil
        }
    }
}

extension TraceEvidenceCopy {
    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "Mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "Vínculo ambíguo entre runs"
        default: return nil
        }
    }
}

/// Copy editorial para `reason` do contrato trace-scoped — nunca inventa motivo.
enum TraceEvidenceCopy {
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }
}

/// Empty/unavailable compartilhado por ArtifactSheet e ChangeReviewSheet.

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        unavailableStack
            .padding(36)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
            .accessibilityIdentifier(identifier)
    }
}

/// Loading compartilhado por ArtifactSheet e ChangeReviewSheet.

struct TraceEvidenceLoading: View {
    let text: String
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 12) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15))
                // Soft gold-quiet trace loading caption.
                .foregroundStyle(AtlasTheme.accent.opacity(0.58))
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        // Live wait state; Reduce Motion keeps a static announcement.
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
    }
}

/// Fala nome, escala atual e ações; silêncio sem inventar dimensões.

enum ArtifactViewerZoomA11y {
    static func spokenImage(name: String, scale: CGFloat) -> String {
        if scale <= 1.01 {
            return "Imagem \(name), tamanho normal"
        }
        let pct = Int((scale * 100).rounded())
        return "Imagem \(name), ampliada \(pct) por cento"
    }

    static let zoomHint = "Pinça para aproximar, arraste quando ampliada, toque duas vezes ou use ações para redefinir"

    static let resetAction = "Redefinir zoom"
}

struct ZoomableArtifactImage: View {
    let image: UIImage
    let name: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero

    var body: some View {
        applyZoomAccessibility(zoomImageCore)
    }
}

extension ZoomableArtifactImage {
    func applyZoomAccessibility<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(ArtifactViewerZoomA11y.spokenImage(name: name, scale: scale))
            .accessibilityHint(ArtifactViewerZoomA11y.zoomHint)
            .accessibilityIdentifier(A11yID.artifactsZoomImage)
            .accessibilityZoomAction { action in
                switch action.direction {
                case .zoomIn:
                    setScale(scale + 0.5)
                case .zoomOut:
                    setScale(scale - 0.5)
                @unknown default:
                    break
                }
            }
            .accessibilityAction(named: ArtifactViewerZoomA11y.resetAction) { resetZoom() }
    }
}

extension ZoomableArtifactImage {
    func clamped(_ value: CGFloat) -> CGFloat {
        min(4, max(1, value))
    }
}

extension ZoomableArtifactImage {
    var zoomImageCore: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .contentShape(Rectangle())
            .gesture(zoomGesture.simultaneously(with: dragGesture))
            .onTapGesture(count: 2) { resetZoom() }
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: scale)
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: offset)
    }
}

extension ZoomableArtifactImage {
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}

extension ZoomableArtifactImage {
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = clamped(lastScale * value)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 { resetOffset() }
            }
    }
}

extension ZoomableArtifactImage {
    func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }
}

extension ZoomableArtifactImage {
    func resetZoom() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        scale = 1
        lastScale = 1
        resetOffset()
    }
}

extension ZoomableArtifactImage {
    func setScale(_ value: CGFloat) {
        scale = clamped(value)
        lastScale = scale
        if scale <= 1 { resetOffset() }
    }
}


struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle)
                .font(AtlasFont.mono(11))
                // Soft gold-quiet artifact ficha meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.58))
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArtifactViewerA11y.spokenFicha(name: name, subtitle: subtitle))
    }
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
    // Execução ao vivo (a orquestra)
    var startedAt: Date? = nil
    var elapsedMs: Int? = nil
    var agents: [ExecAgent] = []
    var decideStage: String? = nil
    var decideStrategy: String? = nil
    var activities: [AtlasAgentActivity] = []
    /// Aviso público do stream resumível. Só aparece quando o InteractionRun
    /// expõe uma tentativa real de reconexão; a View não estima rede.
    var reconnectNotice: String? = nil
    var decisionSummary: AtlasDecisionSummary? = nil
    var qualitySummary: AtlasQualitySummary? = nil
    /// Plano real criado pelo Terminal/CLI; a casca só recebe os dados já
    /// saneados pelo Core, nunca metadata/prompt bruto.
    var executionPlan: AtlasExecutionPlan? = nil
    /// C18: shortstat real do workspace. `nil` = sem workspace / sem medida —
    /// a casca NÃO inventa +0 −0.
    var diffStats: AtlasTraceGovernance.DiffStats? = nil
    /// C19: planos arquivados em replanejamento. Vazio = nunca replanejou.
    var planRevisions: [AtlasTraceGovernance.PlanRevision] = []
    /// Posição do último checkpoint público observado no ledger. `nil` é o
    /// estado honesto para traces legados ou sem checkpoint, não zero falso.
    var executionProgress: AtlasExecutionPlan.Progress? = nil
    /// Estado editorial público e acionável, recebido do ledger/snapshot. A
    /// View nunca deduz atenção, recovery ou falha a partir de texto do modelo.
    var executionPresentationState: AtlasExecutionPresentationState? = nil
    /// Job real que aceitaria uma ação pública. `nil` fora de atenção necessária;
    /// a casca usa este id apenas através de `resolveExecutionChoice`.
    var executionChoiceJobId: JobID? = nil
    /// C17: job real que FALHOU e aceita retry. `nil` quando não há job em
    /// estado falho; a casca só oferece "Retomar" com ele.
    var retryableJobId: JobID? = nil
}

extension ChatBubble {
    var currentActivity: AtlasAgentActivity? { atlasCurrentAgentActivity(from: activities) }

    /// Só renderiza ribbon quando há dado real.
    var hasLiveExecutionSurface: Bool {
        showsReconnectSurface
            || !activities.isEmpty
            || !agents.isEmpty
            || decideStrategy != nil
    }

    /// Dado único para presença do iOS: título de fase e regra de timer vêm do
    /// Core tipado, nunca de uma animação ou de texto do provider.
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

/// Anexo local (pré-envio). O ÚNICO contrato de UI de anexos: a strip do
/// composer renderiza isto e nada mais.
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


/// Fase de carregamento compartilhada pelos models de leitura da casca.
/// ConversationModel fica fora — estado mais rico, não force-fit.
enum LoadPhase: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

extension String {
    /// Trim; nil se vazio.
    var nonEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
// Cycle 044 fuse → AtlasUserMessage.swift

/// Mensagens de erro amigáveis partilhadas entre models da casca.

func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}

func atlasUserMessage(forAPI error: Error) -> String? {
    guard let api = error as? AtlasApiError else { return nil }
    switch api.status {
    case 401, 403: return "A sessão do Atlas precisa ser reconectada."
    case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
    case 500...599: return "O servidor Atlas está temporariamente indisponível."
    default: return api.message
    }
}

func atlasUserMessage(forStream error: Error) -> String? {
    guard error is AtlasInteractionStreamError else { return nil }
    return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
}

func atlasUserMessage(forURL error: Error) -> String? {
    guard let urlError = error as? URLError else { return nil }
    switch urlError.code {
    case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
         .cannotFindHost, .timedOut:
        return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
    default:
        return "Não foi possível falar com o Atlas agora. Tente novamente."
    }
}


/// Feedback editorial do operador — peel de ConversationTypes.
enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }

    var label: String {
        switch self {
        case .util: return "útil"
        case .contexto: return "contexto"
        case .longo: return "longo"
        case .fraco: return "fraco"
        }
    }

    var activeAction: String {
        switch self {
        case .util: return "useful"
        case .contexto: return "wrong_context"
        case .longo: return "too_long"
        case .fraco: return "weak"
        }
    }

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
// ConversationModel+Continuity untouched (Core model territory).

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

func atlasHandoffStatusEditorial(_ status: String) -> String {
    switch status {
    case "ready": return "pronto"
    case "pending": return "enviando"
    default: return status
    }
}

func atlasSurfaceLabel(_ raw: String) -> String {
    switch raw {
    case "atlas_mobile": return "iPhone"
    case "atlas_desktop": return "Mac"
    case "atlas_terminal": return "Terminal"
    default: return raw
    }
}

func editorialThreadPrefix(_ threadId: String) -> String {
    let trimmed = threadId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 12 else { return trimmed }
    return String(trimmed.prefix(12)) + "…"
}


// Cycle 043 fuse → AtlasFailureCopy.swift

/// Copy editorial por `AtlasNetworkFailureKind` — home e conversa compartilham
/// a mesma voz (offline × timeout × recusada × …). Presentation-only.
enum AtlasFailureCopy {
    static func headline(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Falta a chave do Atlas." }
        guard let kind else { return "O servidor está fora de alcance." }
        return networkHeadline(kind: kind) ?? authServerHeadline(kind: kind)
    }
}

extension AtlasFailureCopy {
    static func authServerHint(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .maintenance: return "O servidor pediu uma pausa via Retry-After. O app aguarda você tentar de novo quando a janela terminar."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        default: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHint(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHint(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHint(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func hint(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        guard let kind else {
            return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
        return networkHint(kind: kind) ?? authServerHint(kind: kind)
    }
}

extension AtlasFailureCopy {
    static func authServerHeadline(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        default: return "O servidor está fora de alcance."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHeadline(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHeadline(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        default: return nil
        }
    }
}
