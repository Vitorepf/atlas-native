import SwiftUI
import PhotosUI
import AtlasCore

// Draft seed — peel de ConversationView+InitSeed.

extension ConversationView {
    static func seedDraft(on model: ConversationModel, draft: String) {
        guard !draft.isEmpty else { return }
        model.updateDraft(draft)
    }
}
