import SwiftUI
import AtlasCore

// Peel anti-inchaço — lista e links honestos do WorkspaceView (só threads reais).
// Link → WorkspaceView+ThreadLink.swift
// Caption → WorkspaceView+ListCaption.swift

struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            captionHeader
            ForEach(threads) { t in
                WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion)
                if t.id != threads.last?.id {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
    }
}
