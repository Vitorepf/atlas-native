import SwiftUI
import AtlasCore

/// Achados agrupados pelo EIXO real que o servidor classificou
/// (`finding.category`) — a leitura por frente do mock, com dado verdadeiro.
/// Sem categoria, o achado cai em "gerais": nada é inventado.
struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    private var groups: [String: [AtlasTraceChangeReview.Finding]] {
        Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("ACHADOS · \(findings.count)")
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("achados, \(findings.count) no total")
            ForEach(groups.keys.sorted(), id: \.self) { axis in
                let axisFindings = groups[axis] ?? []
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                            .foregroundStyle(AtlasTheme.accent)
                        Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                        Text("\(axisFindings.count)")
                            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(axisHeaderLabel(axis: axis, count: axisFindings.count))
                    .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
                    ForEach(axisFindings) { f in
                        ChangeReviewFindingRow(finding: f)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }

    private func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(Self.severityColor(severity))
                        .accessibilityHidden(true)
                }
                Text(finding.title ?? "finding").font(.footnote).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
            }
            if let path = finding.filePath {
                Text(path + (finding.startLine.map { ":\($0)" } ?? ""))
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
            }
            if let rec = finding.recommendation {
                Text(rec).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(3).padding(.top, 1)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
        .accessibilityIdentifier(A11yID.reviewFindingRow(finding.id))
    }

    private var rowAccessibilityLabel: String {
        var parts: [String] = []
        if let severity = finding.severity {
            parts.append("severidade \(Self.severitySpoken(severity))")
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

    /// A severidade é do servidor; a cor só traduz — nunca reclassifica.
    private static func severityColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "critical", "high": return AtlasTheme.domOperacional
        case "medium": return AtlasTheme.accent
        default: return AtlasTheme.textTertiary
        }
    }

    private static func severitySpoken(_ s: String) -> String {
        switch s.lowercased() {
        case "critical": return "crítica"
        case "high": return "alta"
        case "medium": return "média"
        case "low": return "baixa"
        default: return s
        }
    }
}
