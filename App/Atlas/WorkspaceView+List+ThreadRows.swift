import SwiftUI
import AtlasCore

// Thread rows + dividers — peel de WorkspaceView+List.

extension WorkspaceThreadsSection {
    @ViewBuilder
    var threadRows: some View {
        ForEach(threads) { t in
            WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion)
            if t.id != threads.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}
