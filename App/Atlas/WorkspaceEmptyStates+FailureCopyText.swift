import SwiftUI
import AtlasCore

// Failure copy text — peel de WorkspaceEmptyStates+FailureCopy.
// Host → WorkspaceEmptyStates+FailureHost.swift

extension AtlasNetworkFailureEmpty {
    var failureCopyText: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            Spacer().frame(height: 12)
            failureHostAndHint
        }
    }
}
