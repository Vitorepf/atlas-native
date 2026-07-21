import SwiftUI
import AtlasCore

// Top bar trailing actions — peel de RootView+Chrome.

extension RootView {
    var topBarTrailing: some View {
        // Só busca: o "+" saiu — a pílula "Escreva ao Atlas" é o único ponto
        // de partida (abre o picker: sem repositório ou um repo por recência).
        CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
            .keyboardShortcut("k", modifiers: .command)
            .accessibilityLabel(searchSpokenLabel())
            .accessibilityHint("abre busca nas conversas carregadas")
            .accessibilityIdentifier(A11yID.topbarSearch)
    }
}
