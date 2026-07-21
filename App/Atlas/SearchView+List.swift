import SwiftUI
import AtlasCore

// Peel anti-inchaço — recentes do SearchView.
// Results → SearchView+Results.swift · ThreadLink → SearchView+ThreadLink.swift
// Caption → SearchView+ListCaption.swift
// RecentLoop → SearchView+List+RecentLoop.swift

struct SearchRecentSection: View {
    let threads: [AtlasAiThread]
    let reduceMotion: Bool

    var body: some View {
        Group {
            recentCaption
            recentThreadLoop
        }
    }
}
