import Foundation

// Severity spoken — peel de ChangeReviewFindingRow+Severity.
// High → ChangeReviewFindingRow+SeveritySpoken+High.swift

extension ChangeReviewFindingRow {
    static func severitySpoken(_ s: String) -> String {
        if let high = severitySpokenHigh(s) { return high }
        switch s.lowercased() {
        case "medium": return "média"
        case "low": return "baixa"
        default: return s
        }
    }
}
