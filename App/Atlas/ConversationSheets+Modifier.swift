import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Observers → ConversationSheets+ModifierObservers.swift
// Review/steer → ConversationSheets+ModifierReview.swift
// Mode/effort → ConversationSheets+ModifierMode.swift

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
        modifierChain(on: content)
    }
}
