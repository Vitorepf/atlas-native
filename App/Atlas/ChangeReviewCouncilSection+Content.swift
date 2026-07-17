import SwiftUI
import AtlasCore

// Governance content — peel de ChangeReviewCouncilSection.
// Stack → ChangeReviewCouncilSection+Content+Stack.swift

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContent(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        if stats != nil || !revisions.isEmpty || !council.isEmpty {
            governanceChrome {
                governanceContentStack(
                    stats: stats,
                    revisions: revisions,
                    council: council
                )
            }
        }
    }
}
