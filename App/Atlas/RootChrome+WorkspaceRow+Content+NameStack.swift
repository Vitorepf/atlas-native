import SwiftUI
import AtlasCore

// Row name stack — peel de RootChrome+WorkspaceRow+Content.

extension WorkspaceRow {
    var workspaceRowNameStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            rowDetail
        }
    }
}
