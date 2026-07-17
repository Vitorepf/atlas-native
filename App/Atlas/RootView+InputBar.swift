import SwiftUI
import AtlasCore

// Input pill — peel de RootView+Chrome (régua ≤100).
// Content → RootView+InputBarContent.swift
// Background → RootView+InputBarBackground.swift

extension RootView {
    @ViewBuilder
    var inputBar: some View {
        Button { path.append(Route.new) } label: {
            inputBarContent
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel(inputPillSpokenLabel())
        .accessibilityHint(newConversationSpokenHint())
        .accessibilityIdentifier(A11yID.homeInputPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(inputBarBackground)
    }
}
