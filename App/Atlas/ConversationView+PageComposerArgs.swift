import SwiftUI
import PhotosUI
import AtlasCore

// ConversationComposer args — peel de ConversationView+PageComposerCard.
// Bindings → ConversationView+PageComposerArgs+Bindings.swift

extension ConversationView {
    var conversationComposerArgs: ConversationComposer {
        let b = conversationComposerSheetBindings
        return ConversationComposer(
            model: model,
            session: session,
            reduceMotion: reduceMotion,
            focused: $focused,
            mode: b.mode,
            showModeSheet: b.showModeSheet,
            showWorkspaceSheet: b.showWorkspaceSheet,
            showEffortSheet: b.showEffortSheet,
            showQueueSheet: b.showQueueSheet,
            showAttachmentSheet: b.showAttachmentSheet,
            pickedPhoto: b.pickedPhoto,
            showFileImporter: b.showFileImporter,
            showCamera: b.showCamera,
            reviewTrace: b.reviewTrace,
            artifactTrace: b.artifactTrace,
            steerTrace: b.steerTrace
        )
    }
}
