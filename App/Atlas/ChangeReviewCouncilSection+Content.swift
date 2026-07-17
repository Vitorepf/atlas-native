import SwiftUI
import AtlasCore

// Governance content — peel de ChangeReviewCouncilSection.
// Council → ChangeReviewCouncilSection+ContentCouncil.swift

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContent(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        if stats != nil || !revisions.isEmpty || !council.isEmpty {
            governanceChrome {
                VStack(alignment: .leading, spacing: 10) {
                    if let stats {
                        governanceStatsLine(stats)
                    }
                    governanceRevisionsLine(revisions)
                    governanceCouncilBlock(council)
                }
            }
        }
    }
}
