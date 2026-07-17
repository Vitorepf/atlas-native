import Foundation

// Severity spoken — peel de ChangeReviewFindingRow+Severity.

extension ChangeReviewFindingRow {
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
