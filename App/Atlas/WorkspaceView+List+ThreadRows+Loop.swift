import SwiftUI
import AtlasCore

// Thread loop — peel de WorkspaceView+List+ThreadRows.

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: ThreadSummary) -> some View {
        WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion)
        threadRowSeparator(after: t)
    }
}
