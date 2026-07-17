import Foundation
import AtlasCore

// Reconnect spoken — peel de ConversationCockpit+Reconnect+Bubble.
// Icon → ConversationCockpit+Reconnect+BubbleIcon.swift
// Core → ConversationCockpit+Reconnect+BubbleSpoken+Core.swift

extension ChatBubble {
    var reconnectSpokenLabel: String {
        var parts = reconnectSpokenCoreParts
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}
