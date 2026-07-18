import SwiftUI
import AtlasCore

// Trailing chevron — peel de ExecutionProof+Expanded+ArtifactsLabel.

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
