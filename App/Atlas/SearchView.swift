import SwiftUI
import AtlasCore

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: recentes reais ou silêncio. Com query:
// título folded (caso+acento insensível). Offline ≠ vazio editorial.
// Query → SearchView+Query · Lista: +Scroll · spoken: +A11y · seções: +List/+Miss.
struct SearchView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var query = ""
    @FocusState var focused: Bool

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SearchViewHeader(query: $query, focused: $focused)
                list
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.searchScreen)
        .accessibilityLabel(spokenSearchScreenLabel())
        .accessibilityHint(Self.searchScreenHint)
        .onAppear { focused = true }
    }
}
