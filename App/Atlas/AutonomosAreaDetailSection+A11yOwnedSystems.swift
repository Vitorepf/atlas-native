import Foundation
import AtlasCore

// Owned systems spoken — peel de AutonomosAreaDetailSection+A11yPlacement.

extension AutonomosAreaDetailA11y {
    static func spokenOwnedSystems(_ systems: [String]) -> String {
        "sistemas sob responsabilidade, \(systems.joined(separator: ", "))"
    }
}
