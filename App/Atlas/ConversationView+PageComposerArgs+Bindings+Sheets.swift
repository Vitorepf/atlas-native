import SwiftUI
import PhotosUI
import AtlasCore

// Sheet flag bindings — peel de ConversationView+PageComposerArgs+Bindings.

extension ConversationView {
    var conversationComposerSheetFlagBindings: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>
    ) {
        (
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            pickedPhoto: $pickedPhoto,
            showFileImporter: $showFileImporter,
            showCamera: $showCamera
        )
    }
}
