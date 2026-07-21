import SwiftUI
import AtlasCore

// Reconnect banner body — peel de ConversationCockpit+Reconnect.

extension ReconnectBanner {
    @ViewBuilder
    func reconnectBannerBody(primary: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ExecutionBanner(
                text: primary,
                icon: bubble.reconnectBannerIcon,
                tint: AtlasTheme.textSecondary,
                reduceMotion: reduceMotion,
                embedInParent: true
            )
            secondaryLines
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bubble.reconnectSpokenLabel)
        .accessibilityIdentifier(A11yID.executionReconnectBanner)
    }
}
