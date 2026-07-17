import SwiftUI
import AtlasCore

// Workspace header back button — peel de WorkspaceView+Chrome.

extension WorkspaceView {
    var headerBackButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
        }
        .accessibilityLabel("voltar")
    }

    var headerSpokenTitle: String {
        if freeOnly { return "conversas sem projeto" }
        return title
    }
}
