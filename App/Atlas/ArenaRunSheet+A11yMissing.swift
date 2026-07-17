import Foundation
import AtlasCore

// Submit missing fields — peel de ArenaRunSheet+A11y.
// Operator → ArenaRunSheet+A11yMissing+Operator.swift
// Suite → ArenaRunSheet+A11yMissing+Suite.swift

extension ArenaRunSheet {
    func spokenSubmitMissing(input: AtlasArenaStartInput) -> String {
        let missing = spokenSubmitMissingOperator(input: input)
            + spokenSubmitMissingSuite(input: input)
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }
}
