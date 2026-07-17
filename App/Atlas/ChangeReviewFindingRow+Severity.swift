import SwiftUI
import AtlasCore

// Severity helpers — peel de ChangeReviewFindingRow+A11y.

extension ChangeReviewFindingRow {
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
