import SwiftUI
import AtlasCore

// MARK: - Seções remanescentes da ChangeReviewSheet (C15 · C16)
// Diff → ChangeReviewDiffSection · Conselho → ChangeReviewCouncilSection.
// Toast/chrome → ChangeReviewSections+Chrome.swift

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(run.decision ?? run.status ?? "revisão")
                    .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                if let finished = run.finishedAt {
                    Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            Spacer()
            if let score = run.score {
                Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES · \(controls.count)")
            ForEach(controls) { c in
                HStack(spacing: 8) {
                    Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                    Text(c.status).font(AtlasFont.mono(10))
                        .foregroundStyle(c.status == "pass" || c.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                    Spacer()
                    Text(c.signalSummary).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(c.slug), status \(c.status), \(c.signalSummary)")
            }
        }
    }
}

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES · \(tests.count)")
            ForEach(tests) { t in
                HStack(spacing: 8) {
                    Text(t.command ?? "teste").font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    Spacer()
                    Text(t.status).font(AtlasFont.mono(10))
                        .foregroundStyle(t.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(t.command ?? "teste"), status \(t.status)")
            }
        }
    }
}

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                HStack(spacing: 8) {
                    Text(a.action == .accept ? "aceito" : "rejeitado")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    if let at = a.actedAt {
                        Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Spacer()
                }
            }
        }
    }
}
