import SwiftUI
import AtlasCore

// Card + sheets — peel de ConversationComposer (régua ≤100).

extension ConversationComposer {
    var composerCard: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            liveExecutionSection
            queueChipSection
            keyboardGrabber
            AttachmentStrip(
                drafts: model.drafts,
                reduceMotion: reduceMotion,
                uploadPercent: model.uploadPercent,
                onRemove: { model.removeDraft($0) },
                onFailedTap: { model.toast = $0 }
            )
            ComposerToolbar(
                model: model,
                reduceMotion: reduceMotion,
                focused: focused,
                expanded: expanded,
                mode: mode,
                liveBubble: liveBubble,
                onAttach: { showAttachmentSheet = true },
                onShowWorkspace: { showWorkspaceSheet = true },
                onShowMode: { showModeSheet = true },
                onShowEffort: { showEffortSheet = true },
                onSend: send
            )
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
