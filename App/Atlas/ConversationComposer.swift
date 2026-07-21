import SwiftUI
import PhotosUI
import AtlasCore

// Composer da conversa — peel de ConversationView (régua anti-inchaço).
// Card → +Card · LiveStrip → +LiveStrip · Actions → +Actions · Fade → +Fade.
// Helpers → ConversationComposer+Helpers.swift
// Shell → ConversationComposer+Shell.swift

struct ConversationComposer: View {
    var model: ConversationModel
    var session: AtlasSession
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding

    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var showFileImporter: Bool
    @Binding var showCamera: Bool
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?

    var body: some View {
        composerShell
    }
}
