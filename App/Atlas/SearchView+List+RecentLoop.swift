import SwiftUI
import AtlasCore

// Recent thread loop — peel de SearchView+List.

extension SearchRecentSection {
    @ViewBuilder
    var recentThreadLoop: some View {
        ForEach(threads) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion)
            if t.id != threads.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}
