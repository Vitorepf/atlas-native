import SwiftUI
import AtlasCore

// Governance stack — peel de ChangeReviewCouncilSection+Content.

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContentStack(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let stats {
                governanceStatsLine(stats)
            }
            governanceRevisionsLine(revisions)
            governanceCouncilBlock(council)
        }
    }
}
