import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel from ChangeReviewSections (canon §7.2 · same domain)

extension ChangeReviewFindingRow {
    var rowAccessibilityLabel: String {
        var parts: [String] = []
        if finding.severity != nil {
            parts.append("severidade \(ChangeReviewJudgment.severitySpoken(finding.severity))")
        }
        parts.append(finding.title ?? "achado sem título")
        if let path = finding.filePath {
            let line = finding.startLine.map { ", linha \($0)" } ?? ""
            parts.append("\(path)\(line)")
        }
        if let rec = finding.recommendation {
            parts.append("recomendação: \(rec)")
        }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewFindingRow {
    var findingBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(ChangeReviewJudgment.severityColor(severity))
                        .accessibilityHidden(true)
                }
                Text(finding.title ?? "finding").font(AtlasFont.serif(14)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            findingPathAndRecommendation
        }
        .padding(.vertical, 3)
    }
}

extension ChangeReviewFindingRow {
    @ViewBuilder
    var findingPathAndRecommendation: some View {
        if let path = finding.filePath {
            Text(path + (finding.startLine.map { ":\($0)" } ?? ""))
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                .accessibilityHidden(true)
        }
        if let rec = finding.recommendation {
            Text(rec).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(3).padding(.top, 1)
                .accessibilityHidden(true)
        }
    }
}

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        findingBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel)
            .accessibilityIdentifier(A11yID.reviewFindingRow(finding.id))
    }
}

extension ChangeReviewFindingsSection {
    func axisGroup(axis: String, axisFindings: [AtlasTraceChangeReview.Finding]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            axisHeaderRow(axis: axis, count: axisFindings.count)
            ForEach(axisFindings) { f in
                ChangeReviewFindingRow(finding: f)
            }
        }
    }
}

extension ChangeReviewFindingsSection {
    func axisHeaderRow(axis: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
            Text("\(count)")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(axisHeaderLabel(axis: axis, count: count))
        .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
    }
}

extension ChangeReviewFindingsSection {
    func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}

extension ChangeReviewFindingsSection {
    /// WAVE-039: axes by worst severity; findings severity-first inside.
    var rankedGroups: [(axis: String, findings: [AtlasTraceChangeReview.Finding])] {
        ChangeReviewJudgment.rankedAxisGroups(findings)
    }
}

struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("ACHADOS · \(findings.count)")
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(ChangeReviewJudgment.spokenFindingsSection(count: findings.count))
            ForEach(rankedGroups, id: \.axis) { group in
                axisGroup(axis: group.axis, axisFindings: group.findings)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }
}
