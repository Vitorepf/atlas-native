import SwiftUI
import AtlasCore

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// A casca renderiza SOMENTE reviews.changeReviewsByTrace[traceId]:
// `unavailable` é um estado explícito com motivo (sem arquivos/botões);
// `available` traz patches, controles, testes e findings persistidos.
// Aceitar/rejeitar só muda a tela depois do recibo do servidor (o model
// garante); diff vem por refreshChangeReviewDiff — nunca rede na View.
// Seções → ChangeReviewSections.swift (comportamento idêntico).
struct ChangeReviewSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Environment(\.dismiss) private var dismiss
    @State private var expandedDiffPatch: String?
    @State private var applying = false

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
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews) }
        }
        .task { await reviews.refreshChangeReview(traceId: traceId) }
    }

    @ViewBuilder
    private var content: some View {
        if let review {
            switch review.state {
            case .unavailable:
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2).foregroundStyle(AtlasTheme.textTertiary)
                    Text("Sem artefatos de revisão nesta execução.")
                        .font(AtlasFont.serif(18, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    if let reason = review.reason {
                        Text(reason).font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(36)
            case .available:
                available(review)
            }
        } else {
            VStack(spacing: 14) {
                ProgressView().tint(AtlasTheme.accent)
                Text("consultando a revisão…")
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    private func available(_ review: AtlasTraceChangeReview) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if let run = review.run { ChangeReviewRunHeader(run: run) }
                ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
                ForEach(review.patches) { patch in
                    ChangeReviewPatchCard(
                        reviews: reviews,
                        traceId: traceId,
                        patch: patch,
                        expandedDiffPatch: $expandedDiffPatch
                    )
                }
                if !review.controls.isEmpty { ChangeReviewControlsSection(controls: review.controls) }
                if !review.testRuns.isEmpty { ChangeReviewTestsSection(tests: review.testRuns) }
                if !review.review.findings.isEmpty { ChangeReviewFindingsSection(findings: review.review.findings) }
                if !review.review.operatorActions.isEmpty {
                    ChangeReviewDecidedSection(actions: review.review.operatorActions)
                }
                ChangeReviewRunActions(
                    review: review,
                    reviews: reviews,
                    traceId: traceId,
                    applying: $applying
                )
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 14)
        }
        .scrollIndicators(.hidden)
    }
}
