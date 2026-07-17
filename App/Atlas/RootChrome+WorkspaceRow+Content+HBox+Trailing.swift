import SwiftUI
import AtlasCore

// HBox trailing — peel de RootChrome+WorkspaceRow+Content+HBox.

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowTrailingStack: some View {
        Spacer(minLength: 8)
        rowTrailing
    }
}
