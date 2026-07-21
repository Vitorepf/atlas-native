import AtlasCore
import SwiftUI

// IDLE-COMPRESS ChangeReviewSections host (peels Governance + RunActions)

enum ChangeReviewSectionsA11y {
    static func spokenCaption(_ text: String) -> String {
        text.lowercased()
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenControl(_ control: AtlasTraceChangeReview.Control) -> String {
        "\(control.slug), status \(control.status), \(control.signalSummary)"
    }

    static func spokenControlsSection(_ controls: [AtlasTraceChangeReview.Control]) -> String {
        let passed = controls.filter { $0.status == "pass" || $0.status == "passed" }.count
        var parts = ["controles, \(controls.count) no total"]
        if passed > 0 { parts.append("\(passed) aprovado\(passed == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenTest(_ test: AtlasTraceChangeReview.TestRun) -> String {
        "\(test.command ?? "teste"), status \(test.status)"
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenTestsSection(_ tests: [AtlasTraceChangeReview.TestRun]) -> String {
        let passed = tests.filter { $0.status == "passed" }.count
        var parts = ["testes, \(tests.count) no total"]
        if passed > 0 { parts.append("\(passed) passou\(passed == 1 ? "" : "ram")") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenDecidedAction(_ action: AtlasTraceChangeReview.OperatorAction) -> String {
        var parts = [action.action == .accept ? "aceito" : "rejeitado"]
        if let at = action.actedAt?.nonEmpty { parts.append(at) }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenDecidedSection(_ actions: [AtlasTraceChangeReview.OperatorAction]) -> String {
        let accepted = actions.filter { $0.action == .accept }.count
        var parts = ["decisões registradas, \(actions.count) no total"]
        if accepted > 0 { parts.append("\(accepted) aceita\(accepted == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenRunHeader(run: AtlasTraceChangeReview.Run) -> String {
        var parts = [run.decision ?? run.status ?? "revisão"]
        if let finished = run.finishedAt?.nonEmpty { parts.append("concluída \(finished)") }
        if let score = run.score { parts.append("pontuação \(score)") }
        return parts.joined(separator: ", ")
    }
}

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    private var ranked: [AtlasTraceChangeReview.Control] {
        ChangeReviewJudgment.rankControls(controls)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES · \(controls.count)")
            ForEach(ranked) { c in
                controlRow(c)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenControlsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }
}

extension ChangeReviewControlsSection {
    func controlRow(_ c: AtlasTraceChangeReview.Control) -> some View {
        HStack(spacing: 8) {
            Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(c.status).font(AtlasFont.mono(10))
                .foregroundStyle(c.status == "pass" || c.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Text(c.signalSummary).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenControl(c))
    }
}

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                decidedActionRow(a)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenDecidedSection(actions))
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }
}

extension ChangeReviewDecidedSection {
    func decidedActionRow(_ a: AtlasTraceChangeReview.OperatorAction) -> some View {
        HStack(spacing: 8) {
            Text(a.action == .accept ? "aceito" : "rejeitado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            if let at = a.actedAt {
                Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenDecidedAction(a))
    }
}

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderScore: some View {
        if let score = run.score {
            Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(run.decision ?? run.status ?? "revisão")
                .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let finished = run.finishedAt {
                Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderFields: some View {
        HStack(spacing: 12) {
            runHeaderTitleStack
            Spacer()
            runHeaderScore
        }
    }
}

extension ChangeReviewTestsSection {
    func testRow(_ t: AtlasTraceChangeReview.TestRun) -> some View {
        HStack(spacing: 8) {
            Text(t.command ?? "teste").font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            Spacer()
            Text(t.status).font(AtlasFont.mono(10))
                .foregroundStyle(t.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenTest(t))
    }
}

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    private var ranked: [AtlasTraceChangeReview.TestRun] {
        ChangeReviewJudgment.rankTests(tests)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES · \(tests.count)")
            ForEach(ranked) { t in
                testRow(t)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenTestsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }
}

// MARK: - Seções remanescentes da ChangeReviewSheet (C15 · C16)
// Diff → ChangeReviewDiffSection · Conselho → ChangeReviewCouncilSection.
// Checks → ChangeReviewSections+Checks.swift
// Chrome → ChangeReviewSections+RunChrome.swift
// Fields → ChangeReviewSections+RunFields.swift

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }
}

extension ChangeReviewSheet {
    func spokenReviewSheetLoadLabel() -> String? {
        if !loadFinished, review == nil { return "revisão de mudanças, consultando" }
        if loadFinished, review == nil { return "revisão de mudanças, indisponível" }
        return nil
    }
}

extension ChangeReviewSheet {
    func spokenReviewSheetLabel() -> String {
        if let load = spokenReviewSheetLoadLabel() { return load }
        guard let review else { return "revisão de mudanças" }
        return spokenReviewSheetAvailableLabel(review)
    }

    static let reviewSheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"
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

