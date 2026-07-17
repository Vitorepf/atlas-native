import SwiftUI
import AtlasCore

// Thread rows + dividers — peel de WorkspaceView+List.
// Separator → WorkspaceView+List+ThreadRows+Separator.swift
// Loop → WorkspaceView+List+ThreadRows+Loop.swift

extension WorkspaceThreadsSection {
    @ViewBuilder
    var threadRows: some View {
        ForEach(threads) { t in
            threadRowLoop(t)
        }
    }
}
