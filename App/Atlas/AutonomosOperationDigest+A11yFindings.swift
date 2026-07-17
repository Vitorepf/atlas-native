import Foundation

// Findings spoken — peel de AutonomosOperationDigest+A11yCounts.

extension AutonomosOperationDigestA11y {
    static func spokenCountFindings(_ findingsByRisk: [String: Int]) -> [String] {
        guard !findingsByRisk.isEmpty else { return [] }
        return [spokenFindings(findingsByRisk)]
    }
}
