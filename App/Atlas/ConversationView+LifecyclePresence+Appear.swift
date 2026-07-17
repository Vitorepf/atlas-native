import SwiftUI
import AtlasCore

// onAppear presence — peel de ConversationView+LifecyclePresence.

extension ConversationView {
    func conversationPresenceOnAppear() {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: model.threadId)
        TurnPresence.shared.setVisible(model, visible: true)
        if startFocused && model.bubbles.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { focused = true }
        }
    }
}
