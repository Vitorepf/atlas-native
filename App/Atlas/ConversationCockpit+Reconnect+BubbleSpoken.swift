import Foundation
import AtlasCore

// Reconnect spoken — peel de ConversationCockpit+Reconnect+Bubble.
// Icon → ConversationCockpit+Reconnect+BubbleIcon.swift

extension ChatBubble {
    var reconnectSpokenLabel: String {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}
