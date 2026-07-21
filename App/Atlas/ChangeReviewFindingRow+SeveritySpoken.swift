import Foundation

// Cycle 040 fuse → ChangeReviewFindingRow+SeveritySpoken.swift

extension ChangeReviewFindingRow {
    static func severitySpokenHigh(_ s: String) -> String? {
        switch s.lowercased() {
        case "critical": return "crítica"
        case "high": return "alta"
        default: return nil
        }
    }
}

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
