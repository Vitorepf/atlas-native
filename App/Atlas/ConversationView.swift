import SwiftUI
import PhotosUI
import AtlasCore

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
