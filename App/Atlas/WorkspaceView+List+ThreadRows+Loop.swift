import SwiftUI
import AtlasCore

// Thread loop — peel de WorkspaceView+List+ThreadRows.

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: AtlasAiThread) -> some View {
        WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion)
        threadRowSeparator(after: t)
    }
}
