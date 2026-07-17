import SwiftUI
import AtlasCore

// Empty conversation suggestions — peel de ConversationMessages+Empty.

extension ConversationMessages {
    @ViewBuilder
    var emptyConversationBody: some View {
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
