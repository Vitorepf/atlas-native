import SwiftUI
import AtlasCore

// Top bar trailing actions — peel de RootView+Chrome.

extension RootView {
    var topBarTrailing: some View {
        HStack(spacing: 12) {
            CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
                .keyboardShortcut("k", modifiers: .command)
                .accessibilityLabel(searchSpokenLabel())
                .accessibilityHint("abre busca nas conversas carregadas")
                .accessibilityIdentifier(A11yID.topbarSearch)
            CircleButton(icon: "plus") { path.append(Route.new(workspaceKey: nil)) }
                .keyboardShortcut("n", modifiers: .command)
                .accessibilityLabel(newConversationSpokenLabel())
                .accessibilityHint(newConversationSpokenHint())
                .accessibilityIdentifier(A11yID.topbarNew)
        }
    }
}
