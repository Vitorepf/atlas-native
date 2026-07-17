import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de WorkspaceRow.
// Trailing → RootChrome+WorkspaceRow+Trailing.swift
// Detail → RootChrome+WorkspaceRow+Detail.swift
// Leading → RootChrome+WorkspaceRow+Content+Leading.swift
// NameStack → RootChrome+WorkspaceRow+Content+NameStack.swift

extension WorkspaceRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            workspaceRowLeading
            workspaceRowNameStack
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}
