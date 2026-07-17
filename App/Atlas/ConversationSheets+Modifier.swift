import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Observers → ConversationSheets+ModifierObservers.swift
// Review/steer → ConversationSheets+ModifierReview.swift

struct ConversationComposerSheetsModifier: ViewModifier {
    var model: ConversationModel
    var session: AtlasSession
    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var showCamera: Bool
    @Binding var showFileImporter: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    let onSteerSubmit: (TraceID, String, AtlasInteractionSteerScope) -> Void

    func body(content: Content) -> some View {
        handoffAndQueueObservers(on:
            attachmentModifiers(on:
                reviewSteerQueueSheets(on:
                    content
                    .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
                    .sheet(isPresented: $showEffortSheet) { EffortSheet(model: model) }
                )
            )
        )
    }
}
