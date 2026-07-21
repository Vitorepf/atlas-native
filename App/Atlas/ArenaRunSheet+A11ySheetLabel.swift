import Foundation
import AtlasCore

// Sheet spoken body — peel de ArenaRunSheet+A11ySheet.
// Hint → ArenaRunSheet+A11ySheetHint.swift
// Engines → ArenaRunSheet+A11yEnginesCount.swift
// Suites → ArenaRunSheet+A11ySuitesCount.swift

extension ArenaRunSheet {
    func spokenSheetLabel() -> String {
        var parts = ["rodar medição Arena"]
        parts.append(spokenEnginesCount())
        parts.append(spokenSuitesCount())
        return parts.joined(separator: ", ")
    }
}
