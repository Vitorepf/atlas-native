import SwiftUI
import AtlasCore

// Submit predicates — peel de ComposerToolbar.

extension ComposerToolbar {
    var canSubmit: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if model.isSending || liveBubble != nil {
            return hasText
        }
        return hasText || !model.drafts.isEmpty
    }
}
