import SwiftUI
import AtlasCore

// Governance chrome — peel de ChangeReviewCouncilSection.

extension ChangeReviewGovernanceSection {
    func governanceChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier(A11yID.reviewGovernance)
    }
}
