import SwiftUI
import AtlasCore

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// A casca renderiza SOMENTE reviews.changeReviewsByTrace[traceId]:
// `unavailable` é um estado explícito com motivo (sem arquivos/botões);
// `available` traz patches, controles, testes e findings persistidos.
// Aceitar/rejeitar só muda a tela depois do recibo do servidor (o model
// garante); diff vem por refreshChangeReviewDiff — nunca rede na View.
// Seções → ChangeReviewSections / DiffSection / CouncilSection (idêntico).
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
            loading("consultando a revisão…")
        } else if loadFinished, review == nil {
            unavailableBody(
                title: "Não foi possível consultar a revisão.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.reviewLoadFailure,
                spoken: "não foi possível consultar a revisão"
            )
        } else if let review {
            switch review.state {
            case .unavailable:
                unavailableBody(
                    title: "Sem revisão de mudanças nesta execução.",
                    subtitle: TraceEvidenceCopy.unavailableReason(review.reason),
                    identifier: A11yID.reviewUnavailable,
                    spoken: TraceEvidenceCopy.unavailableSpoken(
                        prefix: "sem revisão de mudanças nesta execução",
                        reason: review.reason
                    )
                )
            case .available:
                if Self.hasReviewSurface(review) {
                    available(review)
                } else {
                    unavailableBody(
                        title: "Revisão ligada, mas sem patches nem provas publicadas.",
                        subtitle: "o servidor confirmou o vínculo, porém não há diff, checks ou achados a mostrar.",
                        identifier: A11yID.reviewEmpty,
                        spoken: "revisão ligada mas sem patches nem provas publicadas"
                    )
                }
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

    private func loading(_ text: String) -> some View {
        VStack(spacing: 14) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private func unavailableBody(
        title: String,
        subtitle: String?,
        identifier: String,
        spoken: String
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(title)
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(36)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
        .accessibilityIdentifier(identifier)
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
