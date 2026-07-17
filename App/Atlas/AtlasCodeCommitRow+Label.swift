import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de AtlasCodeCommitRow.

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
                HStack(spacing: 6) {
                    Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
                        .accessibilityHidden(true)
                    Text("·")
                        .accessibilityHidden(true)
                    Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
                        .accessibilityHidden(true)
                    if let ruleId {
                        Text("·")
                            .accessibilityHidden(true)
                        Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                            .foregroundStyle(color)
                            .accessibilityHidden(true)
                    }
                }
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }

    var commitAccessibilityHint: String {
        guard !isDimmed else { return "" }
        if onLongPress != nil { return "abre proveniência do commit; pressione e segure para opções" }
        return "abre proveniência do commit"
    }
}
