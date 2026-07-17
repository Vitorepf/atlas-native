import SwiftUI
import AtlasCore

// Hero glyph + prompt — peel de EmptyConversation.
// Glyph → ConversationEmptyStates+Hero+Glyph.swift
// Prompt → ConversationEmptyStates+Hero+Prompt.swift

extension EmptyConversation {
    var heroStack: some View {
        VStack(spacing: 0) {
            heroGlyph
            Spacer().frame(height: 40)
            heroPromptBlock
            Spacer().frame(height: 44)
            suggestionStack
        }
    }
}
