import SwiftUI
import AtlasCore

// HBox leading — peel de RootChrome+WorkspaceRow+Content+HBox.
// Name → RootChrome+WorkspaceRow+Content+HBox+Name.swift
// Trailing → RootChrome+WorkspaceRow+Content+HBox+Trailing.swift

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowLeadingStack: some View {
        workspaceRowLeading
        workspaceRowNameStack
    }
}
