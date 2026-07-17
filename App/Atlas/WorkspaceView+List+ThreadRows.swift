import SwiftUI
import AtlasCore

// Thread rows + dividers — peel de WorkspaceView+List.
// Separator → WorkspaceView+List+ThreadRows+Separator.swift

extension WorkspaceThreadsSection {
    @ViewBuilder
    var threadRows: some View {
        ForEach(threads) { t in
            WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion)
            threadRowSeparator(after: t)
        }
    }
}
