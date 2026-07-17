import SwiftUI
import AtlasCore

// Campo de busca — peel de SearchViewHeader.

extension SearchViewHeader {
    var searchFieldCapsule: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            ZStack(alignment: .leading) {
                Text("Buscar conversas")
                    .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                    .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
                    .accessibilityHidden(true)
                TextField("", text: $query)
                    .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                    .tint(AtlasTheme.accent).focused($focused)
                    .submitLabel(.search)
                    .accessibilityLabel(spokenFieldLabel)
                    .accessibilityHint("filtra só conversas já carregadas na sessão")
                    .accessibilityIdentifier(A11yID.searchField)
            }
            if !query.isEmpty {
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("limpar busca")
                .accessibilityHint("remove o texto e volta aos recentes")
                .accessibilityIdentifier(A11yID.searchClear)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(Capsule().fill(AtlasTheme.surface)
            .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: focused)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: query.isEmpty)
    }

    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}
