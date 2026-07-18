import SwiftUI
import AtlasCore

// Row leading icon — peel de RootChrome+WorkspaceRow+Content.

extension WorkspaceRow {
    var workspaceRowLeading: some View {
        // Hierarchical: o SF ganha profundidade de dois tons (régua premium).
        Image(systemName: icon)
            .symbolRenderingMode(.hierarchical)
            .atlasSans(18).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            .accessibilityHidden(true)
    }
}
