import SwiftUI
import AtlasCore

// Diff stats line — peel de ExecutingStrip+StatusMeta.

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusDiffStats: some View {
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
