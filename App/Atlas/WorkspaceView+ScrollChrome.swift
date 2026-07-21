import SwiftUI
import AtlasCore

// Workspace list chrome — peel de WorkspaceView+Scroll.

extension WorkspaceView {
    func workspaceListChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
    }
}
