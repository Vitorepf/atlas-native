import SwiftUI
import AtlasCore

// Draft/attachment gate — peel de ComposerToolbar+CanSubmit.

extension ComposerToolbar {
    var canSubmitFromDraft: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || !model.drafts.isEmpty
    }
}
