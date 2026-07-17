import SwiftUI
import AtlasCore

extension ConversationView {
    func conversationLifecycleModifiers<Content: View>(_ content: Content) -> some View {
        content
            .task { await model.load() }
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
