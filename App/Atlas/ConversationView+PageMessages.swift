import SwiftUI
import PhotosUI
import AtlasCore

// ConversationMessages bind — peel de ConversationView+PageParts.

extension ConversationView {
    var conversationMessagesView: some View {
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
