import SwiftUI
import AtlasCore

// Conselho C21 — peel de ChangeReviewCouncilSection.

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        let diverged = AtlasTraceGovernance.councilDiverged(council)
        VStack(alignment: .leading, spacing: 6) {
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
            ForEach(council) { member in
                ChangeReviewCouncilMemberRow(member: member)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewCouncilA11y.spokenSection(memberCount: council.count, diverged: diverged))
        .accessibilityIdentifier(A11yID.reviewCouncil)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: council.map(\.id))
    }
}
