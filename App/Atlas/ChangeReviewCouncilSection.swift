import SwiftUI
import AtlasCore

// MARK: - Governance / Conselho (C18 · C19 · C21)
// Stats/Revisions → +StatsLine/+RevisionsLine · Council block → +Block.swift
// Chrome → ChangeReviewCouncilSection+Chrome.swift
// Content → ChangeReviewCouncilSection+Content.swift

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
            governanceContent(stats: stats, revisions: revisions, council: council)
        }
    }
}
