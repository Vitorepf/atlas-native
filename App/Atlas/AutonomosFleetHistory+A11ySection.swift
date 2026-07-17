import Foundation
import AtlasCore

/// Section spoken — peel de AutonomosFleetHistory+A11y.

enum AutonomosFleetHistoryA11ySection {
    static let visibleCap = 6

    static func spokenSection(total: Int) -> String {
        guard total > 0 else { return "histórico da frota vazio" }
        if total > visibleCap {
            return "histórico da frota, \(visibleCap) de \(total) eventos recentes"
        }
        return "histórico da frota, \(total) evento\(total == 1 ? "" : "s")"
    }
}
