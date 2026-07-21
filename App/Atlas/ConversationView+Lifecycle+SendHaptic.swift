import SwiftUI
import AtlasCore

// Send haptic — peel de ConversationView+Lifecycle.

extension ConversationView {
    func applySendHaptic<Content: View>(_ content: Content) -> some View {
        content
            .onChange(of: model.isSending) { was, now in
                if was && !now { AtlasMotion.successNotification(reduceMotion: reduceMotion) }
            }
    }
}
