import SwiftUI
import AtlasCore

// Empty + bubbles LazyVStack — peel de ConversationMessages (régua ≤100).
// Rows → ConversationMessages+Rows.swift
// Stack → ConversationMessages+BubblesStack.swift

extension ConversationMessages {
    @ViewBuilder
    func messagesList() -> some View {
        if model.bubbles.isEmpty {
            emptyMessages()
        } else {
            bubblesStack
        }
    }
}
