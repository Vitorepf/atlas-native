import SwiftUI
import AtlasCore

// Title stack — peel de ArenaRunSheet+ToggleLabel.

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelTitleStack(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            toggleSubtitle(subtitle)
        }
    }
}
