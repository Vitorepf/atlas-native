import SwiftUI
import AtlasCore

// Commit title stack — peel de AtlasCodeCommitRow+Label.

extension AtlasCodeCommitRow {
    var commitRowTextStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleText)
                .atlasSans(14, .medium)
                .foregroundStyle(state == .violating ? color : AtlasTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .accessibilityHidden(true)
            commitMetaLine
        }
    }
}
