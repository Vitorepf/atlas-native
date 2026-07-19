import SwiftUI
import AtlasCore

// Input pill — peel de RootView+Chrome (régua ≤100).
// Content → RootView+InputBarContent.swift
// Background → RootView+InputBarBackground.swift

extension RootView {
    @ViewBuilder
    var inputBar: some View {
        // A pílula é o ÚNICO ponto de partida (o "+" saiu): abre o picker do
        // Cursor — "Sem repositório" (conversa geral) ou um repo por recência.
        Button { showingNewPicker = true } label: {
            inputBarContent
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel(inputPillSpokenLabel())
        .accessibilityHint(inputPillSpokenHint())
        .accessibilityIdentifier(A11yID.homeInputPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(inputBarBackground)
        .sheet(isPresented: $showingNewPicker) {
            AtlasWorkspacePickerSheet(
                client: session.client,
                title: "Nova conversa",
                onNoRepo: {
                    showingNewPicker = false
                    path.append(Route.new(workspaceKey: nil))
                }
            ) { key, title in
                showingNewPicker = false
                path.append(Route.workspace(key: key, title: title))
            }
        }
    }
}
