import SwiftUI
import AtlasCore

// Label visual do retry — peel de WorkspaceEmptyStates+Retry.

extension AtlasNetworkFailureEmpty {
    var retryLabel: some View {
        Text("Tentar de novo")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 22).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
    }
}
