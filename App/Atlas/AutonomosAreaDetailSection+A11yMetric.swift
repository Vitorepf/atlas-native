import Foundation

// Metric spoken — peel de AutonomosAreaDetailSection+A11yPlacement.

extension AutonomosAreaDetailA11y {
    static func spokenMetric(label: String, value: Int?) -> String {
        guard let value else { return "\(label) não publicado" }
        return "\(value) \(label)"
    }
}
