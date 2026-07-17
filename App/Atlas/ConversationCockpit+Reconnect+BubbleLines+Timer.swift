import Foundation
import AtlasCore

// Active timer — peel de ConversationCockpit+Reconnect+BubbleLines.

extension ChatBubble {
    var reconnectActiveTimerMs: Int? {
        guard streaming,
              executionPresentationState?.kind == .recovering,
              let timer = executionPresentationState?.timer
        else { return nil }
        return timer.elapsedActiveMilliseconds
    }
}
