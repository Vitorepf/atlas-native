import SwiftUI
import PhotosUI
import AtlasCore

// Conversation page messages stack — peel de ConversationView+Page.

extension ConversationView {
    var conversationMessagesStack: some View {
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
    }

    var conversationComposerBind: some View {
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
}
