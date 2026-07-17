import SwiftUI
import AtlasCore

// Trailing chevron — peel de ExecutionProof+Expanded+ArtifactsLabel.

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
