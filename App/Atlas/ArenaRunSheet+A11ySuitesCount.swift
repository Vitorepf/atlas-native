import Foundation
import AtlasCore

// Suites count spoken — peel de ArenaRunSheet+A11ySheetLabel.

extension ArenaRunSheet {
    func spokenSuitesCount() -> String {
        let suites = installedSuites.count
        if suites == 0 {
            return "nenhuma suite com adapter"
        }
        return "\(suites) suite\(suites == 1 ? "" : "s") instalada\(suites == 1 ? "" : "s")"
    }
}
