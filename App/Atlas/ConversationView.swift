import SwiftUI
import AtlasCore
import PhotosUI

// IDLE-COMPRESS fused ConversationView · ConversationView.swift

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
    /// Home partida only — unlocks default empty catalog via Judgment (WAVE-084).
    let isHomePartida: Bool
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
        isHomePartida: Bool = false,
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
        self.isHomePartida = isHomePartida
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
    func spokenConversationEmptyPrefix() -> String? {
        if model.loadError != nil, model.bubbles.isEmpty {
            return "\(title), falha ao carregar"
        }
        if model.bubbles.isEmpty {
            let organ = ConversationEmptyJudgment.spokenEmptyOrgan(
                prompt: emptyPrompt,
                suggestions: emptySuggestions,
                isHomePartida: isHomePartida,
                hasWorkspaces: !session.workspaces.isEmpty
            )
            return "\(title), \(organ)"
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
        UIAccessibility.post(notification: .announcement, argument: ConversationMessagesJudgment.spokenToast(message))
    }

    func clearToast() {
        if reduceMotion { model.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { model.toast = nil } }
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
            .accessibilityLabel(spokenConversationScreenLabel())
            .accessibilityHint(
                hidesNavigationBack
                    ? "arraste para baixo para fechar"
                    : ConversationMessagesJudgment.screenHint
            )
            .overlay(alignment: .top) { toast }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.toast)
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

