import SwiftUI
import AtlasCore

// Conversation lifecycle — peel de ConversationView.
// Presence → ConversationView+LifecyclePresence.swift

extension ConversationView {
    func conversationLifecycleModifiers<Content: View>(_ content: Content) -> some View {
        conversationPresenceModifiers(content)
            .task { await model.load() }
            .onChange(of: model.isSending) { was, now in
                if was && !now { AtlasMotion.successNotification(reduceMotion: reduceMotion) }
            }
            .onChange(of: model.cacheCapturedAt) { _, capturedAt in
                if let capturedAt { lastCacheCapturedAt = capturedAt }
            }
            .sheet(isPresented: $showOutline) {
                ConversationOutlineSheet(bubbles: model.bubbles, reduceMotion: reduceMotion)
            }
            .onChange(of: model.showingStaleCache) { was, now in
                if now, let capturedAt = model.cacheCapturedAt {
                    lastCacheCapturedAt = capturedAt
                } else if was && !now, lastCacheCapturedAt != nil {
                    readSealConfirming = true
                }
            }
    }
}
