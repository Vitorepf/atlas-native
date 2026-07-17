import SwiftUI
import AtlasCore

// Trailing branch — peel de ComposerToolbar+Trailing.

extension ComposerToolbar {
    @ViewBuilder
    var trailingControlBranch: some View {
        if canSubmit {
            trailingSendButton
        } else if isExecuting {
            trailingProcessing
        } else {
            trailingOptionsMenu
        }
    }
}
