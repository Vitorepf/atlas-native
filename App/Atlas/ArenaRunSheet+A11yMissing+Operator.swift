import Foundation
import AtlasCore

// Operator missing fields — peel de ArenaRunSheet+A11yMissing.

extension ArenaRunSheet {
    func spokenSubmitMissingOperator(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        return missing
    }
}
