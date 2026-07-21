import Foundation
import AtlasCore

// Reconnect banner icon — peel de ConversationCockpit+Reconnect+BubbleSpoken.

extension ChatBubble {
    var reconnectBannerIcon: String {
        executionPresentationState?.kind == .recovering
            ? "arrow.triangle.2.circlepath"
            : "wifi.exclamationmark"
    }
}
