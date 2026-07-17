import Foundation
import AtlasCore

// Engines count spoken — peel de ArenaRunSheet+A11ySheetLabel.

extension ArenaRunSheet {
    func spokenEnginesCount() -> String {
        if engines.isEmpty {
            return "nenhum motor publicado"
        }
        return "\(engines.count) motor\(engines.count == 1 ? "" : "es")"
    }
}
