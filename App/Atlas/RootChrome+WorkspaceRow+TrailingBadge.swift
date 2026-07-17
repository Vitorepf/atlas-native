import SwiftUI

// Trailing badge — peel de RootChrome+WorkspaceRow+Trailing.

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingBadge: some View {
        if badge {
            Circle()
                .fill(AtlasTheme.alert)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
        }
    }
}
