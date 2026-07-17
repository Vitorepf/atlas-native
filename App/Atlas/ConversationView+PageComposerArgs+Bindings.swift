import SwiftUI
import PhotosUI
import AtlasCore

// Sheet/trace bindings — peel de ConversationView+PageComposerArgs.
// Sheets → ConversationView+PageComposerArgs+Bindings+Sheets.swift
// Trace → ConversationView+PageComposerArgs+Bindings+Trace.swift

extension ConversationView {
    var conversationComposerSheetBindings: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        let sheets = conversationComposerSheetFlagBindings
        let traces = conversationComposerTraceBindings
        return (
            mode: sheets.mode,
            showModeSheet: sheets.showModeSheet,
            showWorkspaceSheet: sheets.showWorkspaceSheet,
            showEffortSheet: sheets.showEffortSheet,
            showQueueSheet: sheets.showQueueSheet,
            showAttachmentSheet: sheets.showAttachmentSheet,
            pickedPhoto: sheets.pickedPhoto,
            showFileImporter: sheets.showFileImporter,
            showCamera: sheets.showCamera,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace
        )
    }
}
