import SwiftUI
import AtlasCore

/// Conteúdo loading / unavailable / available — peel de ChangeReviewSheet (régua ≤100).
/// Surface → ChangeReviewView+Surface.swift

extension ChangeReviewSheet {
    @ViewBuilder
    var content: some View {
        if !loadFinished, review == nil {
            TraceEvidenceLoading(text: "consultando a revisão…", reduceMotion: reduceMotion)
        } else if loadFinished, review == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar a revisão.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.reviewLoadFailure,
                spoken: "não foi possível consultar a revisão",
                systemImage: "doc.text.magnifyingglass"
            )
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
