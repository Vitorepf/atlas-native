import AtlasCore
import SwiftUI

// Cycle 041 fuse → ChangeReviewView+Chrome.swift

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableContent(_ review: AtlasTraceChangeReview) -> some View {
        switch review.state {
        case .unavailable:
            reviewUnavailableContent(review)
        case .available:
            reviewAvailableBranch(review)
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableBranch(_ review: AtlasTraceChangeReview) -> some View {
        if Self.hasReviewSurface(review) {
            ChangeReviewAvailableContent(
                reviews: reviews,
                traceId: traceId,
                review: review,
                expandedDiffPatch: $expandedDiffPatch,
                applying: $applying
            )
        } else {
            reviewEmptySurface()
        }
    }
}

// de Sections a estendem; a definição não chegou ao merge).

struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        reviewSections
    }
}

extension ChangeReviewSheet {
    func reviewUnavailableContent(_ review: AtlasTraceChangeReview) -> some View {
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
    }
}

extension ChangeReviewSheet {
    func reviewEmptySurface() -> some View {
        TraceEvidenceUnavailable(
            title: "Revisão ligada, mas sem patches nem provas publicadas.",
            subtitle: "o servidor confirmou o vínculo, porém não há diff, checks ou achados a mostrar.",
            identifier: A11yID.reviewEmpty,
            spoken: "revisão ligada mas sem patches nem provas publicadas",
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

extension ChangeReviewSheet {
    var reviewSheetChrome: some View {
        NavigationStack {
            // Fundo como .background: destrava o scroll-edge material da barra.
            content
                .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Revisar mudanças")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { reviewToolbar }
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews, reduceMotion: reduceMotion) }
            .accessibilityIdentifier(A11yID.reviewSheet)
            .accessibilityLabel(spokenReviewSheetLabel())
            .accessibilityHint(Self.reviewSheetHint)
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    var content: some View {
        if review == nil {
            reviewUnavailableContent
        } else if let review {
            reviewAvailableContent(review)
        }
    }
}

extension ChangeReviewSheet {
    func refreshReviewTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
    }
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSections: some View {
        if let run = review.run { ChangeReviewRunHeader(run: run) }
        ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
        reviewPatchTail
    }
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewPatchTail: some View {
        ForEach(review.patches) { patch in
            ChangeReviewPatchCard(
                reviews: reviews,
                traceId: traceId,
                patch: patch,
                expandedDiffPatch: $expandedDiffPatch
            )
        }
        reviewSectionsAfterPatches
    }
}

extension ChangeReviewSheet {
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

extension ChangeReviewSheet {
    var reviewToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                spokenLabel: "fechar revisão de mudanças",
                spokenHint: "volta para a conversa",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    var reviewUnavailableContent: some View {
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
        }
    }
}
