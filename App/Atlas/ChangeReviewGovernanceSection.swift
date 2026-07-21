import SwiftUI
import AtlasCore

// Trace lookup — peel de ChangeReviewGovernanceSection.

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    var governanceTraceGate: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)
            governanceContent(stats: stats, revisions: revisions, council: council)
        }
    }
}
