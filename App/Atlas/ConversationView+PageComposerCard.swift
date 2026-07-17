import SwiftUI
import PhotosUI
import AtlasCore

// Composer card bind — peel de ConversationView+PageComposer.

extension ConversationView {
    var conversationComposerCard: some View {
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
