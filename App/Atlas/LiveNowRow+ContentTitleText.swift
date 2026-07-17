import SwiftUI
import AtlasCore

// Title text — peel de LiveNowRow+ContentTitle.

extension LiveNowRow {
    var rowTitleText: some View {
        Text(session.title)
            .font(AtlasFont.serif(16, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(2)
            .layoutPriority(1)
    }
}
