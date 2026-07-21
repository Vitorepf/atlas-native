import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de WorkspaceRow.
// HBox → RootChrome+WorkspaceRow+Content+HBox.swift

extension WorkspaceRow {
    var rowContent: some View {
        workspaceRowHBox
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
    }
}
