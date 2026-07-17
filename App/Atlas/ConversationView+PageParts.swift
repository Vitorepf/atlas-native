import SwiftUI
import PhotosUI
import AtlasCore

// Conversation page messages stack — peel de ConversationView+Page.
// Composer → ConversationView+PageComposer.swift

extension ConversationView {
    var conversationMessagesStack: some View {
        VStack(spacing: 0) {
            header
            cacheAgeSeal
            handoffReceipt
            ConversationMessages(
                model: model,
                reduceMotion: reduceMotion,
                emptyPrompt: emptyPrompt,
                emptySuggestions: emptySuggestions,
                awayFromBottom: $awayFromBottom,
                lastScrollAt: $lastScrollAt,
                lastScrollBubbleCount: $lastScrollBubbleCount,
                reviewTrace: $reviewTrace,
                artifactTrace: $artifactTrace,
                steerTrace: $steerTrace,
                onEditResend: editAndResend,
                onCopy: copy
            )
        }
    }
}
