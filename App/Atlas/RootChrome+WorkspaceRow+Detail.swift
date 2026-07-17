import SwiftUI
import AtlasCore

// Detail text do WorkspaceRow — peel de RootChrome+WorkspaceRow+Content.

extension WorkspaceRow {
    @ViewBuilder
    var rowDetail: some View {
        if let detail, !detail.isEmpty {
            Text(detail)
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.alert)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
