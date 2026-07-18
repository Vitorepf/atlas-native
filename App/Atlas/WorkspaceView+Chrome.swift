import SwiftUI
import AtlasCore

// Workspace screen a11y chrome — peel de WorkspaceView.

extension WorkspaceView {
    func workspaceScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationBarHidden(true)
            .atlasSwipeBack()
            .accessibilityIdentifier(A11yID.workspaceScreen)
            .accessibilityLabel(spokenWorkspaceScreenLabel())
            .accessibilityHint(workspaceScreenHint)
    }
}
