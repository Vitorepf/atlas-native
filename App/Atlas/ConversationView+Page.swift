import SwiftUI
import PhotosUI
import AtlasCore

// Página editorial + composer — peel de ConversationView (régua ≤100).

extension ConversationView {
    @ViewBuilder
    var conversationPage: some View {
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
        .accessibilityIdentifier(A11yID.conversationScreen)
        .accessibilityLabel(spokenConversationScreenLabel())
        .accessibilityHint(ConversationViewA11y.screenHint)
        .overlay(alignment: .top) { toast }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.toast)
    }
}
