import Foundation

// Stale suffix — peel de FleetWidgetA11y spoken label.

extension FleetWidgetA11y {
    static func spokenStaleSuffix(stale: Bool, age: String) -> String? {
        stale ? "visto \(age)" : nil
    }
}
