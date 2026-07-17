import SwiftUI
import AtlasCore

// Row leading icon — peel de RootChrome+WorkspaceRow+Content.

extension WorkspaceRow {
    var workspaceRowLeading: some View {
        Image(systemName: icon)
            .font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            .accessibilityHidden(true)
    }
}
