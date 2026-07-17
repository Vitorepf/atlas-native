import SwiftUI
import AtlasCore

// Spoken + severity — peel de ChangeReviewFindingRow.

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

    static func severityColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "critical", "high": return AtlasTheme.domOperacional
        case "medium": return AtlasTheme.accent
        default: return AtlasTheme.textTertiary
        }
    }

    static func severitySpoken(_ s: String) -> String {
        switch s.lowercased() {
        case "critical": return "crítica"
        case "high": return "alta"
        case "medium": return "média"
        case "low": return "baixa"
        default: return s
        }
    }
}
