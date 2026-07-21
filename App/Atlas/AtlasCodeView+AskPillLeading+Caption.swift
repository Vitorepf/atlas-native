import SwiftUI
import AtlasCore

// Ask pill caption stack — peel de AtlasCodeView+AskPillLeading.

extension AtlasCodeView {
    var askPillCaptionStack: some View {
        HStack(spacing: 12) {
            RootView.HomeComposerStar()
            Text(anchorLegend ?? AtlasCodeAskContext.invite)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
                .accessibilityIdentifier(A11yID.codeAskAnchorNote)
        }
    }
}
