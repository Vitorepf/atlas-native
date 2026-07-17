import Foundation
import AtlasCore

// Suite/engine missing fields — peel de ArenaRunSheet+A11yMissing.

extension ArenaRunSheet {
    func spokenSubmitMissingSuite(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        return missing
    }
}
