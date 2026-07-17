import SwiftUI
import AtlasCore

// Retry CTA — peel de WorkspaceEmptyStates / AtlasNetworkFailureEmpty.

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    var retryButton: some View {
        let button = Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRetry()
        } label: {
            Text("Tentar de novo")
                .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 22).padding(.vertical, 10)
                .background(Capsule().fill(AtlasTheme.goldVeil)
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("tentar de novo")
        .accessibilityHint(retryHint)

        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}
