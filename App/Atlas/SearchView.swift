import SwiftUI
import AtlasCore

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: recentes reais ou silêncio. Com query:
// título folded (caso+acento insensível). Offline ≠ vazio editorial.
// Query → SearchView+Query · Lista: +Scroll · spoken: +A11y · seções: +List/+Miss.
// A11y → SearchView+A11yChrome.swift
struct SearchView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var query = ""
    @FocusState var focused: Bool

    var body: some View {
        searchA11yChrome(searchBackgroundShell)
    }
}
