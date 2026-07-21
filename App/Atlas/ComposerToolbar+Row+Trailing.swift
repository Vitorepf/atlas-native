import SwiftUI
import AtlasCore

// Row trailing slot — peel de ComposerToolbar+Row.

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowTrailing: some View {
        trailingControl
    }
}
