import Foundation
import AtlasCore

/// currentActivity — peel de ConversationTypes.

extension ChatBubble {
    var currentActivity: AtlasAgentActivity? { atlasCurrentAgentActivity(from: activities) }
}
