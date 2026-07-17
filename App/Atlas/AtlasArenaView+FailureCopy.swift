import SwiftUI
import AtlasCore

// Failure copy — peel de AtlasArenaView+Failure.

extension AtlasArenaView {
    func networkFailureCopy(kind: AtlasNetworkFailureKind, hasToken: Bool) -> some View {
        Group {
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineSpacing(4)
                .accessibilityHidden(true)
        }
    }
}
