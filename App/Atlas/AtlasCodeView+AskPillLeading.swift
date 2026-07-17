import SwiftUI
import AtlasCore

// Ask pill leading content — peel de AtlasCodeView+AskPillContent.

extension AtlasCodeView {
    var askPillLeading: some View {
        HStack(spacing: 9) {
            Text("✦")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Text(anchorLegend ?? "pergunte sobre este repositório")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
                .accessibilityIdentifier(A11yID.codeAskAnchorNote)
            Spacer(minLength: 0)
            askPillClearButton
            Image(systemName: "chevron.up")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}
