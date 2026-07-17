import SwiftUI
import AtlasCore

// Failure host/hint — peel de WorkspaceEmptyStates+FailureCopyText.

extension AtlasNetworkFailureEmpty {
    var failureHostAndHint: some View {
        Group {
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        }
    }
}
