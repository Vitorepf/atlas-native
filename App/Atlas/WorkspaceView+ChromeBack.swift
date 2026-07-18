import SwiftUI
import AtlasCore

// Workspace header back button — peel de WorkspaceView+Chrome.

extension WorkspaceView {
    /// Header composto (reconstruído pós-merge: o peel deixou só as folhas).
    var header: some View {
        HStack(spacing: 12) {
            headerBackButton
            Spacer()
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityLabel(headerSpokenTitle)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    var headerBackButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
        }
        .accessibilityLabel("voltar")
    }

    var headerSpokenTitle: String {
        if freeOnly { return "conversas sem projeto" }
        return title
    }
}
