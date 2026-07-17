import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Folhas do composer — peels de ConversationView (régua anti-inchaço).
// Modifier → ConversationSheets+Modifier.swift.

struct ConversationReviewTraceRef: Identifiable { let id: TraceID }
struct ConversationSteerTraceRef: Identifiable { let id: TraceID }

extension View {
    func conversationComposerSheets(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        steerReceipt: @escaping (TraceID) -> AtlasInteractionSteerResponse?,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifier(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            steerReceipt: steerReceipt,
            onSteerSubmit: onSteerSubmit
        )
    }
}
