import SwiftUI
import AtlasCore

// Thread loop — peel de SearchView+Results.

extension SearchResultsSection {
    /// Mesma régua da lista de Conversas: "novo" na maioria de 6+ linhas
    /// não discrimina — silencia em bloco.
    var newBadgeSaturated: Bool {
        results.count >= 6
            && results.lazy.filter(ConversationModel.hasNewerContent).count * 2 > results.count
    }

    @ViewBuilder
    var resultsThreadLoop: some View {
        let saturated = newBadgeSaturated
        ForEach(results) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: saturated)
            if t.id != results.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}
