import SwiftUI
import AtlasCore

// onDisappear presence — peel de ConversationView+LifecyclePresence.

extension ConversationView {
    func conversationPresenceOnDisappear() {
        TurnPresence.shared.setVisible(model, visible: false)
        model.markThreadVisited()
    }
}
