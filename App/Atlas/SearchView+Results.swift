import SwiftUI
import AtlasCore

// Resultados da busca — peel de SearchView+List.
// Caption → SearchView+ResultsCaption.swift

struct SearchResultsSection: View {
    let results: [AtlasAiThread]
    let query: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            resultsCaption
            ForEach(results) { t in
                SearchThreadLink(thread: t, reduceMotion: reduceMotion)
                if t.id != results.last?.id {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
    }
}
