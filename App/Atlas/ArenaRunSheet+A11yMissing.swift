import Foundation
import AtlasCore

// Submit missing fields — peel de ArenaRunSheet+A11y.

extension ArenaRunSheet {
    func spokenSubmitMissing(input: AtlasArenaStartInput) -> String {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }
}
