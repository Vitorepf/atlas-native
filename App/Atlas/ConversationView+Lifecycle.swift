import SwiftUI
import AtlasCore

// Conversation lifecycle — peel de ConversationView.
// Cache → ConversationView+LifecycleCache.swift
// Presence → ConversationView+LifecyclePresence.swift
// Outline → ConversationView+LifecycleOutline.swift

extension ConversationView {
    func conversationLifecycleModifiers<Content: View>(_ content: Content) -> some View {
        conversationOutlineSheet(
            conversationPresenceModifiers(
                applySendHaptic(
                    applyCacheLifecycleModifiers(content)
                        .task { await model.load() }
                )
            )
        )
    }
}
