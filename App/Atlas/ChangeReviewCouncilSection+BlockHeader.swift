import SwiftUI
import AtlasCore

// Council block header — peel de ChangeReviewCouncilSection+Block.

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlockHeader(diverged: Bool) -> some View {
        HStack(spacing: 8) {
            Text("Conselho")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityAddTraits(.isHeader)
            if diverged {
                Text("divergência")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel("divergência entre pareceres")
            }
        }
    }
}
