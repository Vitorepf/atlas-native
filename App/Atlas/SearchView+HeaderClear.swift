import SwiftUI
import AtlasCore

// Clear button — peel de SearchView+HeaderField.

extension SearchViewHeader {
    @ViewBuilder
    var searchClearButton: some View {
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

    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}
