import SwiftUI

// Severity color — peel de ChangeReviewFindingRow+Severity.

extension ChangeReviewFindingRow {
    static func severityColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "critical", "high": return AtlasTheme.domOperacional
        case "medium": return AtlasTheme.accent
        default: return AtlasTheme.textTertiary
        }
    }
}
