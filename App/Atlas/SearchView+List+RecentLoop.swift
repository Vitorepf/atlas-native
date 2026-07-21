import SwiftUI
import AtlasCore

// Recent thread loop — peel de SearchView+List.

extension SearchRecentSection {
    /// Mesma régua da lista de Conversas: saturado silencia em bloco.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var recentThreadLoop: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: saturated)
            if t.id != threads.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}
