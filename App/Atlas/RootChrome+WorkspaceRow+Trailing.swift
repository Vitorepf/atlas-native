import SwiftUI
import AtlasCore

// Trailing count/badge — peel de WorkspaceRow.
// Badge → RootChrome+WorkspaceRow+TrailingBadge.swift · Count → +TrailingCount

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingBadge
        rowTrailingCount
    }
}
