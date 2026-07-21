import AtlasCore
import SwiftUI

// Cycle 041 fuse → ConversationEmptyStates.swift

struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = a conversa do Atlas, que é sobre tudo.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    let onSuggestion: (String) -> Void
    @State var breathe = false

    var body: some View {
        heroStack
            .padding(.horizontal, 32).padding(.top, 56)
            .frame(maxWidth: .infinity)
            .onAppear { startBreathing() }
            .accessibilityElement(children: .contain)
    }
}
