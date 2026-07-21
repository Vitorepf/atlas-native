import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: was ChangeReviewSections — controls · tests · decided · run header

// MARK: - Controls

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
        .accessibilityLabel(ChangeReviewJudgment.spokenControlsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }

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
        .accessibilityLabel(ChangeReviewJudgment.spokenControl(c))
    }
}

// MARK: - Decided actions

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
        .accessibilityLabel(ChangeReviewJudgment.spokenDecidedSection(actions))
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }

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
        .accessibilityLabel(ChangeReviewJudgment.spokenDecidedAction(a))
    }
}

// MARK: - Tests

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
        .accessibilityLabel(ChangeReviewJudgment.spokenTestsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }

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
        .accessibilityLabel(ChangeReviewJudgment.spokenTest(t))
    }
}

// MARK: - Run header

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }

    @ViewBuilder
    var runHeaderFields: some View {
        HStack(spacing: 12) {
            runHeaderTitleStack
            Spacer()
            runHeaderScore
        }
    }

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

    @ViewBuilder
    var runHeaderScore: some View {
        if let score = run.score {
            Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}
