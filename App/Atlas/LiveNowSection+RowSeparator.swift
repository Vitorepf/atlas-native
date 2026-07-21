import SwiftUI

// Hub separator — peel de LiveNowSection+Rows.

enum LiveNowRowSeparator {
    static var hub: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.55))
            .frame(height: 1)
            .padding(.vertical, 10)
            .accessibilityHidden(true)
    }
}
