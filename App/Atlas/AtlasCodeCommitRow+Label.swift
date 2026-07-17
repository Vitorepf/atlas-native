import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de AtlasCodeCommitRow.
// Meta → AtlasCodeCommitRow+Meta.swift
// Text stack → AtlasCodeCommitRow+Label+TextStack.swift

extension AtlasCodeCommitRow {
    var commitRowLabel: some View {
        HStack(alignment: .top, spacing: 12) {
            spine
            commitRowTextStack
            Spacer(minLength: 0)
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }
}
