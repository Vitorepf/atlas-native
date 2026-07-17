import SwiftUI
import AtlasCore

// Hub count badges — peel de LiveNowSection+Header.

extension LiveNowSection {
    @ViewBuilder
    var hubCountBadges: some View {
        if isHub {
            Text("× \(sessions.count)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            if remoteCount > 0 {
                Text("· \(remoteCount) remota\(remoteCount == 1 ? "" : "s")")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
