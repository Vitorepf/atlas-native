import SwiftUI
import AtlasCore

// Pílula nova conversa — peel de WorkspaceView+ChromeFilter.
// Label → WorkspaceView+ChromeNewPillLabel.swift

extension WorkspaceView {
    var newPill: some View {
        // A conversa nova nasce NESTE workspace (livres → sem workspace).
        NavigationLink(value: Route.new(workspaceKey: freeOnly ? nil : workspaceKey)) {
            newPillLabel
        }
        .buttonStyle(.plain)
        .accessibilityLabel("nova conversa")
        .accessibilityHint("abre o compositor para escrever ao Atlas")
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
