import SwiftUI
import AtlasCore

// Sending gate — peel de ComposerToolbar+CanSubmit.

extension ComposerToolbar {
    var canSubmitWhileSending: Bool {
        !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
