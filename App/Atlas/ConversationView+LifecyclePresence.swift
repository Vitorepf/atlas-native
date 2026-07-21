import SwiftUI
import AtlasCore

// Conversation appear/disappear presence — peel de ConversationView+Lifecycle.
// Appear → ConversationView+LifecyclePresence+Appear.swift
// ThreadChange → ConversationView+LifecyclePresence+ThreadChange.swift
// Disappear → ConversationView+LifecyclePresence+Disappear.swift

extension ConversationView {
    func conversationPresenceModifiers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { conversationPresenceOnAppear() }
            .onChange(of: model.threadId) { _, now in conversationPresenceOnThreadChange(now) }
            .onDisappear { conversationPresenceOnDisappear() }
    }
}
