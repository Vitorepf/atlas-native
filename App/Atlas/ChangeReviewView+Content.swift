import SwiftUI
import AtlasCore

/// Conteúdo loading / unavailable / available — peel de ChangeReviewSheet (régua ≤100).
/// Surface → ChangeReviewView+Surface.swift
/// Unavailable → ChangeReviewView+Unavailable.swift

extension ChangeReviewSheet {
    @ViewBuilder
    var content: some View {
        if review == nil {
            reviewUnavailableContent
        } else if let review {
            switch review.state {
            case .unavailable:
                TraceEvidenceUnavailable(
                    title: "Sem revisão de mudanças nesta execução.",
                    subtitle: TraceEvidenceCopy.unavailableReason(review.reason),
                    identifier: A11yID.reviewUnavailable,
                    spoken: TraceEvidenceCopy.unavailableSpoken(
                        prefix: "sem revisão de mudanças nesta execução",
                        reason: review.reason
                    ),
                    systemImage: "doc.text.magnifyingglass"
                )
            case .available:
                if Self.hasReviewSurface(review) {
                    ChangeReviewAvailableContent(
                        reviews: reviews,
                        traceId: traceId,
                        review: review,
                        expandedDiffPatch: $expandedDiffPatch,
                        applying: $applying
                    )
                } else {
                    TraceEvidenceUnavailable(
                        title: "Revisão ligada, mas sem patches nem provas publicadas.",
                        subtitle: "o servidor confirmou o vínculo, porém não há diff, checks ou achados a mostrar.",
                        identifier: A11yID.reviewEmpty,
                        spoken: "revisão ligada mas sem patches nem provas publicadas",
                        systemImage: "doc.text.magnifyingglass"
                    )
                }
            }
        }
    }
}
