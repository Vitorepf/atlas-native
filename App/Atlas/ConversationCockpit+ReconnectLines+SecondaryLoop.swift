import SwiftUI
import AtlasCore

// Secondary lines loop — peel de ConversationCockpit+ReconnectLines.

extension ReconnectBanner {
    @ViewBuilder
    var reconnectSecondaryLoop: some View {
        ForEach(Array(bubble.reconnectSecondaryLines.enumerated()), id: \.offset) { _, line in
            Text(line)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}
