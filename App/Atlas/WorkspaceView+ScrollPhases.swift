import SwiftUI
import AtlasCore

// Scroll phases — peel de WorkspaceView+Scroll.

extension WorkspaceView {
    @ViewBuilder
    var scrollPhaseContent: some View {
        if showsLoadingShell {
            WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                .accessibilityIdentifier(A11yID.workspaceLoading)
        } else if showsNetworkFailure {
            listNetworkFailure
        } else {
            listLoadedContent
        }
    }
}
