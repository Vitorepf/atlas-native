import SwiftUI
import AtlasCore

// MARK: - Governance / Conselho (C18 · C19 · C21)
// Lines → ChangeReviewCouncilSection+Lines.swift · Council block → +Block.swift

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)

            if stats != nil || !revisions.isEmpty || !council.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    if let stats {
                        governanceStatsLine(stats)
                    }
                    governanceRevisionsLine(revisions)
                    if !council.isEmpty {
                        councilBlock(council)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier(A11yID.reviewGovernance)
            }
        }
    }
}
