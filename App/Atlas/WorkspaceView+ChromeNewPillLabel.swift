import SwiftUI
import AtlasCore

// New pill label — peel de WorkspaceView+ChromeNewPill.

extension WorkspaceView {
    // Mesma pílula agêntica da home: ✦ + chrome canônico. Sem mic (canon §6).
    var newPillLabel: some View {
        HStack(spacing: 12) {
            RootView.HomeComposerStar()
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
