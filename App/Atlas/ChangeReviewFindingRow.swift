import SwiftUI
import AtlasCore

/// Linha de achado — peel de ChangeReviewFindingsSection.

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
