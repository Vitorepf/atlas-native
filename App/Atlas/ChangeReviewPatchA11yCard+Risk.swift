import Foundation
import AtlasCore

// Patch risk spoken — peel de ChangeReviewPatchA11yCard.
// DiffState → ChangeReviewPatchA11yCard+DiffState.swift

extension ChangeReviewPatchA11yCard {
    static func spokenRiskFlags(_ flags: [String]) -> String? {
        guard !flags.isEmpty else { return nil }
        return "alertas \(flags.joined(separator: ", "))"
    }
}
