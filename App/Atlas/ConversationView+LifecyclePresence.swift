import SwiftUI
import AtlasCore

// Conversation appear/disappear presence — peel de ConversationView+Lifecycle.

extension ConversationView {
    func conversationPresenceModifiers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                TurnPresence.shared.watch(model, threadTitle: title, threadId: model.threadId)
                TurnPresence.shared.setVisible(model, visible: true)
                if startFocused && model.bubbles.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { focused = true }
                }
            }
            .onChange(of: model.threadId) { _, now in
                TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
                TurnPresence.shared.setVisible(model, visible: true)
                if let now { onThread?(now) }
            }
            .onDisappear {
                TurnPresence.shared.setVisible(model, visible: false)
                model.markThreadVisited()
            }
    }
}
