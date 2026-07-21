import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → SearchView.swift

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: recentes reais ou silêncio. Com query:
// título folded (caso+acento insensível). Offline ≠ vazio editorial.
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

extension SearchView {
    var searchBackgroundShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            searchLayout
        }
    }
}

extension SearchView {
    var searchLayout: some View {
        VStack(spacing: 0) {
            SearchViewHeader(query: $query, focused: $focused)
            list
        }
    }
}

struct SearchViewHeader: View {
    @Binding var query: String
    @FocusState.Binding var focused: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            searchBackButton
            searchFieldCapsule
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }
}

extension SearchViewHeader {
    var searchBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).atlasGlassCircle()
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a busca")
    }
}

extension SearchViewHeader {
    func clearSearchQuery() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        query = ""
    }
}

extension SearchViewHeader {
    @ViewBuilder
    var searchClearButton: some View {
        if !query.isEmpty {
            searchClearA11y(
                Button(action: clearSearchQuery) {
                    searchClearIcon
                }
            )
        }
    }
}

extension SearchViewHeader {
    func searchClearA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityLabel("limpar busca")
            .accessibilityHint("remove o texto e volta aos recentes")
            .accessibilityIdentifier(A11yID.searchClear)
    }
}

extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension SearchViewHeader {
    var searchFieldCapsule: some View {
        searchFieldLeading
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: focused)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: query.isEmpty)
    }
}

extension SearchViewHeader {
    var searchFieldInput: some View {
        ZStack(alignment: .leading) {
            searchFieldPlaceholder
            TextField("", text: $query)
                .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .tint(AtlasTheme.accent).focused($focused)
                .submitLabel(.search)
                .accessibilityLabel(spokenFieldLabel)
                .accessibilityHint("filtra só conversas já carregadas na sessão")
                .accessibilityIdentifier(A11yID.searchField)
        }
    }
}

extension SearchViewHeader {
    var searchFieldLeading: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            searchFieldInput
            searchClearButton
        }
    }
}

extension SearchViewHeader {
    var searchFieldPlaceholder: some View {
        Text("Buscar conversas")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
            .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension SearchViewHeader {
    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}
