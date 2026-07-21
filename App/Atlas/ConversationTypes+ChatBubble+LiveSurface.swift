import Foundation
import AtlasCore

/// Superfície viva do cockpit — peel de ConversationTypes.

extension ChatBubble {
    /// Só renderiza ribbon quando há dado real.
    var hasLiveExecutionSurface: Bool {
        showsReconnectSurface
            || !activities.isEmpty
            || !agents.isEmpty
            || decideStrategy != nil
    }
}
