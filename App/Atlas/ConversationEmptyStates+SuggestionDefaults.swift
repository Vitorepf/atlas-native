import SwiftUI
import AtlasCore

// Default suggestion copy — peel de ConversationEmptyStates+Suggestions.

extension EmptyConversation {
    /// Defaults = partida Home (sem inventar contagens). Superfícies com pack
    /// próprio passam `suggestionsOverride` (Arena/Código/Autônomos).
    var defaultSuggestions: [String] {
        HomeAskContext.emptySuggestions(hasWorkspaces: false)
    }
}
