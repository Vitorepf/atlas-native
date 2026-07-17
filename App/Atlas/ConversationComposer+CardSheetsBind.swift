import SwiftUI
import AtlasCore

// Sheets bind — peel de ConversationComposer+Card.

extension ConversationComposer {
    func composerCardSheets<V: View>(_ card: V) -> some View {
        card.conversationComposerSheets(
            model: model,
            session: session,
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto,
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}
