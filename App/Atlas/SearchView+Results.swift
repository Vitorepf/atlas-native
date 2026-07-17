import SwiftUI
import AtlasCore

// Resultados da busca — peel de SearchView+List.
// Caption → SearchView+ResultsCaption.swift
// ThreadLoop → SearchView+Results+ThreadLoop.swift

struct SearchResultsSection: View {
    let results: [AtlasAiThread]
    let query: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            resultsCaption
            resultsThreadLoop
        }
    }
}
