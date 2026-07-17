import Foundation

// High severity spoken — peel de ChangeReviewFindingRow+SeveritySpoken.

extension ChangeReviewFindingRow {
    static func severitySpokenHigh(_ s: String) -> String? {
        switch s.lowercased() {
        case "critical": return "crítica"
        case "high": return "alta"
        default: return nil
        }
    }
}
