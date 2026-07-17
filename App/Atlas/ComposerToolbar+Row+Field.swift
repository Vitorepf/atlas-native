import SwiftUI
import AtlasCore

// Row field slot — peel de ComposerToolbar+Row.

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowField: some View {
        composerTextField
    }
}
