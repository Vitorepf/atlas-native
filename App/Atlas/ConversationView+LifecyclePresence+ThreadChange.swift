import SwiftUI
import AtlasCore

// onChange threadId — peel de ConversationView+LifecyclePresence.

extension ConversationView {
    func conversationPresenceOnThreadChange(_ now: ThreadID?) {
        TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
        TurnPresence.shared.setVisible(model, visible: true)
        if let now { onThread?(now) }
    }
}
