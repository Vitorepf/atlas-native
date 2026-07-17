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
                applyCacheLifecycleModifiers(content)
                    .task { await model.load() }
                    .onChange(of: model.isSending) { was, now in
                        if was && !now { AtlasMotion.successNotification(reduceMotion: reduceMotion) }
                    }
            )
        )
    }
}
