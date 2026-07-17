import SwiftUI
import AtlasCore

// Peel anti-inchaço — recentes do SearchView.
// Results → SearchView+Results.swift · ThreadLink → SearchView+ThreadLink.swift
// Caption → SearchView+ListCaption.swift

struct SearchRecentSection: View {
    let threads: [AtlasAiThread]
    let reduceMotion: Bool

    var body: some View {
        Group {
            recentCaption
            ForEach(threads) { t in
                SearchThreadLink(thread: t, reduceMotion: reduceMotion)
                if t.id != threads.last?.id {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
    }
}
