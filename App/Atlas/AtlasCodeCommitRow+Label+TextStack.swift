import SwiftUI
import AtlasCore

// Commit title stack — peel de AtlasCodeCommitRow+Label.
// HEAD ganha véu dourado suave (mockup AX v4).

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, isFirst ? 4 : 0)
        .padding(.horizontal, isFirst ? 8 : 0)
        .background {
            if isFirst {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AtlasTheme.accent.opacity(0.07), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}
