import SwiftUI
import AtlasCore

// Ask button label — peel de AtlasCodeProvenanceSections+Ask.

extension AtlasCodeProvenanceSheet {
    var askButtonLabel: some View {
        HStack(spacing: 8) {
            Text("✦")
                .font(AtlasFont.serif(12))
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Text("perguntar sobre este commit")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            Image(systemName: "arrow.up.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .atlasCard(cornerRadius: 12)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
