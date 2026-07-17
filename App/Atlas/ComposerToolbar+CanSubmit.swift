import SwiftUI
import AtlasCore

// Submit predicates — peel de ComposerToolbar.

extension ComposerToolbar {
    var canSubmit: Bool {
        if model.isSending || liveBubble != nil {
            return canSubmitWhileSending
        }
        return canSubmitFromDraft
    }
}
