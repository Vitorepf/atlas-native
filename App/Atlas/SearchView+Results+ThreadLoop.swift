import SwiftUI
import AtlasCore

// Thread loop — peel de SearchView+Results.

extension SearchResultsSection {
    @ViewBuilder
    var resultsThreadLoop: some View {
        ForEach(results) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion)
            if t.id != results.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}
