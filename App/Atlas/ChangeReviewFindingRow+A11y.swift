import AtlasCore
import SwiftUI

// Cycle 041 fuse → ChangeReviewFindingRow+A11y.swift

extension ChangeReviewFindingRow {
    var rowAccessibilityLabel: String {
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

extension ChangeReviewFindingRow {
    static func severityColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "critical", "high": return AtlasTheme.domOperacional
        case "medium": return AtlasTheme.accent
        default: return AtlasTheme.textTertiary
        }
    }
}
