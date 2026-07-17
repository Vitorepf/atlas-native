import SwiftUI
import AtlasCore

// Title captions — peel de ArenaIndexSection+Header.

extension ArenaIndexSection {
    var sectionHeaderTitle: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("O ÍNDICE")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(coverageCaption)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
