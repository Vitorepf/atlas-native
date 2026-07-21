import SwiftUI
import AtlasCore

// WAVE-149

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }
}

extension ChangeReviewSheet {
    /// WAVE-063: exclusive sheet face from loadFinished + review.
    var reviewSheetFace: ChangeReviewSheetFace {
        ChangeReviewSheetJudgment.face(loadFinished: loadFinished, review: review)
    }

    func spokenReviewSheetLabel() -> String {
        ChangeReviewSheetJudgment.spokenSheet(loadFinished: loadFinished, review: review)
    }

    static var reviewSheetHint: String { ChangeReviewSheetJudgment.sheetHint }
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
        ChangeReviewRiskStrip(review: review)
        ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
        reviewPatchTail
    }
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSectionsAfterPatches: some View {
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
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewPatchTail: some View {
        // WAVE-039: riskFlags-first patches before quiet ones.
        ForEach(ChangeReviewJudgment.rankPatches(review.patches)) { patch in
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
        ChangeReviewJudgment.hasReviewSurface(review)
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

