import SwiftUI
import AtlasCore

// Commit title stack — peel de AtlasCodeCommitRow+Label.

extension AtlasCodeCommitRow {
    var commitRowTextStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(node.message ?? String(node.hash.prefix(8)))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(state == .violating ? color : AtlasTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .accessibilityHidden(true)
            commitMetaLine
        }
    }
}
