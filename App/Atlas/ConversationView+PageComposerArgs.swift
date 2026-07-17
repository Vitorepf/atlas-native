import SwiftUI
import PhotosUI
import AtlasCore

// ConversationComposer args — peel de ConversationView+PageComposerCard.

extension ConversationView {
    var conversationComposerArgs: ConversationComposer {
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
