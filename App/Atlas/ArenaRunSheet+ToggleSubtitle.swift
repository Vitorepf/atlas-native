import SwiftUI
import AtlasCore

// Toggle subtitle — peel de ArenaRunSheet+ToggleLabel.

extension ArenaRunSheet {
    @ViewBuilder
    func toggleSubtitle(_ subtitle: String?) -> some View {
        if let subtitle {
            Text(subtitle)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
