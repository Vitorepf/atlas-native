import SwiftUI
import AtlasCore

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// Conteúdo disponível → ChangeReviewView+Available.swift
struct ChangeReviewSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expandedDiffPatch: String?
    @State private var applying = false
    @State private var loadFinished = false

    private var review: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }

    var body: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("Revisar mudanças")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Fechar") { dismiss() } }
            }
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews, reduceMotion: reduceMotion) }
            .accessibilityIdentifier(A11yID.reviewSheet)
        }
        .task {
            await reviews.refreshChangeReview(traceId: traceId)
            loadFinished = true
        }
    }

    @ViewBuilder
    private var content: some View {
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

    /// Patches, checks, testes ou achados — nunca UI vazia fingindo conteúdo.
    static func hasReviewSurface(_ review: AtlasTraceChangeReview) -> Bool {
        !review.patches.isEmpty
            || !review.controls.isEmpty
            || !review.testRuns.isEmpty
            || !review.review.findings.isEmpty
            || !review.review.operatorActions.isEmpty
            || !review.review.availableActions.isEmpty
    }
}
