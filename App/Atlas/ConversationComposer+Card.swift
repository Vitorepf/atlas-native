import SwiftUI
import AtlasCore

// Card + sheets — peel de ConversationComposer (régua ≤100).
// Body → ConversationComposer+CardBody.swift

extension ConversationComposer {
    var composerCard: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            composerCardBody
        }
        .padding(expanded ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
                          : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            ConversationComposerA11y.spokenCard(
                expanded: expanded,
                draftCount: model.drafts.count,
                queueCount: model.queuedMessages.count,
                isSending: model.isSending
            )
        )
        .accessibilityHint(ConversationComposerA11y.cardHint)
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
