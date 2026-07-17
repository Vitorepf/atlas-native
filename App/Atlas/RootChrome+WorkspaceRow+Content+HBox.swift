import SwiftUI
import AtlasCore

// Row HStack — peel de RootChrome+WorkspaceRow+Content.
// Leading → RootChrome+WorkspaceRow+Content+HBox+Leading.swift
// Trailing → RootChrome+WorkspaceRow+Content+HBox+Trailing.swift

extension WorkspaceRow {
    var workspaceRowHBox: some View {
        HStack(spacing: 14) {
            workspaceRowLeadingStack
            workspaceRowTrailingStack
        }
    }
}
