import SwiftUI
import PhotosUI
import AtlasCore

// Conversation page composer bind — peel de ConversationView+PageParts.

extension ConversationView {
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
