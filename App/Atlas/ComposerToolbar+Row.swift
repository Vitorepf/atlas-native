import SwiftUI
import AtlasCore

// Composer toolbar row — peel de ComposerToolbar.

extension ComposerToolbar {
    var toolbarRow: some View {
        HStack(spacing: 10) {
            attachButton
            composerTextField
            trailingControl
        }
        .accessibilityElement(children: .contain)
    }
}
