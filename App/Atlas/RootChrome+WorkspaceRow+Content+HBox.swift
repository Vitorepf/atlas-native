import SwiftUI
import AtlasCore

// Row HStack — peel de RootChrome+WorkspaceRow+Content.

extension WorkspaceRow {
    var workspaceRowHBox: some View {
        HStack(spacing: 14) {
            workspaceRowLeading
            workspaceRowNameStack
            Spacer(minLength: 8)
            rowTrailing
        }
    }
}
