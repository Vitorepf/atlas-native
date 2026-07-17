import SwiftUI
import AtlasCore

// Peel anti-inchaço — lista e links honestos do WorkspaceView (só threads reais).
// Link → WorkspaceView+ThreadLink.swift
// Caption → WorkspaceView+ListCaption.swift
// Rows → WorkspaceView+List+ThreadRows.swift

struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            captionHeader
            threadRows
        }
    }
}
