import Foundation
import AtlasCore

// Spoken labels — peel de ArenaRunSheet (CICLO C residual honesty).
// Receipt → ArenaRunSheet+A11yReceipt.swift · Sheet/close → +A11ySheet.swift
// Empty → ArenaRunSheet+A11yEmpty.swift
// Missing → ArenaRunSheet+A11yMissing.swift
// Hint → ArenaRunSheet+A11yHint.swift

extension ArenaRunSheet {
    func spokenSubmitLabel(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "rodar medição"
        }
        if enginesEmpty {
            return "rodar medição indisponível, nenhum motor publicado"
        }
        return spokenSubmitMissing(input: input)
    }
}
