import SwiftUI
import AtlasCore

// Meta author/time/law — peel de AtlasCodeCommitRow+Label.

extension AtlasCodeCommitRow {
    var commitMetaLine: some View {
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

    var commitAccessibilityHint: String {
        guard !isDimmed else { return "" }
        if onLongPress != nil { return "abre proveniência do commit; pressione e segure para opções" }
        return "abre proveniência do commit"
    }
}
