import SwiftUI
import PhotosUI
import AtlasCore

// A conversa — a base da comunicação. Metáfora de PÁGINA EDITORIAL, não bolhas
// SaaS: o turno do operador é uma citação com barra bronze; o do Atlas é uma
// página cheia (markdown editorial) com assinatura de provider, feedback
// governado e streaming vivo. Composer: ConversationComposer.swift.
// Turnos: ConversationMessages.swift. Folhas: ConversationSheets.swift.
// Chrome: ConversationViewChrome.swift · Init: ConversationView+Init.swift
// Lifecycle: ConversationView+Lifecycle.swift
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) private var session
    @State var model: ConversationModel
    @State private var mode = "geral"
    @State private var showModeSheet = false
    @State private var showWorkspaceSheet = false
    @State private var showEffortSheet = false
    @State private var showQueueSheet = false
    @State var showOutline = false
    @State private var reviewTrace: ConversationReviewTraceRef?
    @State private var artifactTrace: ConversationReviewTraceRef?
    @State private var steerTrace: ConversationSteerTraceRef?
    @State private var showAttachmentSheet = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var showCamera = false
    @FocusState var focused: Bool
    @State private var awayFromBottom = false
    @State var readSealConfirming = false
    @State var lastCacheCapturedAt: Date?
    @State private var lastScrollAt: CFAbsoluteTime = 0
    @State private var lastScrollBubbleCount = 0

    let startFocused: Bool
    let emptyPrompt: String?
    let emptySuggestions: [String]?
    let onThread: ((ThreadID) -> Void)?

    var body: some View {
        conversationLifecycleModifiers(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    cacheAgeSeal
                    handoffReceipt
                    ConversationMessages(
                        model: model,
                        reduceMotion: reduceMotion,
                        emptyPrompt: emptyPrompt,
                        emptySuggestions: emptySuggestions,
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
                ConversationComposer(
                    model: model,
                    session: session,
                    reduceMotion: reduceMotion,
                    focused: $focused,
                    mode: $mode,
                    showModeSheet: $showModeSheet,
                    showWorkspaceSheet: $showWorkspaceSheet,
                    showEffortSheet: $showEffortSheet,
                    showQueueSheet: $showQueueSheet,
                    showAttachmentSheet: $showAttachmentSheet,
                    pickedPhoto: $pickedPhoto,
                    showFileImporter: $showFileImporter,
                    showCamera: $showCamera,
                    reviewTrace: $reviewTrace,
                    artifactTrace: $artifactTrace,
                    steerTrace: $steerTrace
                )
            }
            .navigationBarHidden(true)
            .overlay(alignment: .top) { toast }
        )
    }
}
