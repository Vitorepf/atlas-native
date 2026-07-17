import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de AtlasCodeCommitRow.
// Meta → AtlasCodeCommitRow+Meta.swift

extension AtlasCodeCommitRow {
    var commitRowLabel: some View {
        HStack(alignment: .top, spacing: 12) {
            spine
            VStack(alignment: .leading, spacing: 4) {
                // Manchete: a mensagem do commit. Sem mensagem, o hash é o
                // último recurso honesto — nunca inventamos um título.
                Text(node.message ?? String(node.hash.prefix(8)))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(state == .violating ? color : AtlasTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .accessibilityHidden(true)
                commitMetaLine
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }
}
