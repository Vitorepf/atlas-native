import SwiftUI
import AtlasCore

// Council block branch — peel de ChangeReviewCouncilSection+Content.

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceCouncilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        if !council.isEmpty {
            councilBlock(council)
        }
    }
}
