import SwiftUI
import AtlasCore

// Conteúdo visual do input pill — peel de RootView+InputBar.

extension RootView {
    // A pílula agêntica: ✦ vivo + chrome canônico Home (atlasAgenticPillChrome).
    var inputBarContent: some View {
        HStack(spacing: 12) {
            HomeComposerStar()
            Text(HomeAskContext.invite)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .atlasAgenticPillChrome()
    }
}
