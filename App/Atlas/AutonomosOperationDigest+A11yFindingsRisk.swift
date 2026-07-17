import Foundation

// Findings risk spoken — peel de AutonomosOperationDigest+A11yHeadlines.

extension AutonomosOperationDigestA11y {
    static func spokenFindings(_ findings: [String: Int]) -> String {
        let pairs = findings.sorted { $0.value > $1.value }.map { "\($0.key) \($0.value)" }
        return "achados por risco, \(pairs.joined(separator: ", "))"
    }
}
