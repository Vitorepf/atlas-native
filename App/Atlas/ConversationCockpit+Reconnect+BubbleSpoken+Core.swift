import Foundation
import AtlasCore

// Reconnect notice/state spoken — peel de ConversationCockpit+Reconnect+BubbleSpoken.

extension ChatBubble {
    var reconnectSpokenCoreParts: [String] {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        return parts
    }
}
