import SwiftUI
import AtlasCore

// Sheets bind — peel de ConversationComposer+Card.
// Flags → ConversationComposer+CardSheetsBind+Flags.swift
// Traces → ConversationComposer+CardSheetsBind+Traces.swift

extension ConversationComposer {
    func composerCardSheets<V: View>(_ card: V) -> some View {
        let flags = composerCardSheetFlagArgs
        let traces = composerCardSheetTraceArgs
        return card.conversationComposerSheets(
            model: model,
            session: session,
            mode: flags.mode,
            showModeSheet: flags.showModeSheet,
            showWorkspaceSheet: flags.showWorkspaceSheet,
            showEffortSheet: flags.showEffortSheet,
            showQueueSheet: flags.showQueueSheet,
            showAttachmentSheet: flags.showAttachmentSheet,
            showCamera: flags.showCamera,
            showFileImporter: flags.showFileImporter,
            pickedPhoto: flags.pickedPhoto,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}
