import SwiftUI
import AtlasCore

// Card + sheets — peel de ConversationComposer (régua ≤100).
// Body → ConversationComposer+CardBody.swift
// Chrome → ConversationComposer+CardChrome.swift
// Surface → ConversationComposer+CardSurface.swift

extension ConversationComposer {
    var composerCard: some View {
        composerCardSurface
            .conversationComposerSheets(
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
