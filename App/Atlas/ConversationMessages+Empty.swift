import SwiftUI
import AtlasCore

// Empty state — peel de ConversationMessages+Rows.

extension ConversationMessages {
    @ViewBuilder
    func emptyMessages() -> some View {
        if model.loadError != nil {
            AtlasNetworkFailureEmpty(
                kind: model.loadFailureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 100,
                retryHint: "reconecta e recarrega esta conversa",
                accessibilityIdentifier: A11yID.conversationLoadFailure,
                onRetry: { Task { await model.load() } }
            )
        } else {
            EmptyConversation(
                reduceMotion: reduceMotion,
                prompt: emptyPrompt,
                suggestions: emptySuggestions
            ) { suggestion in
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                let effort = model.effort
                Task { await model.send(suggestion, effort: effort) }
            }
        }
    }
}
