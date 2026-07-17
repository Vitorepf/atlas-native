import Foundation
import AtlasCore

// Patch risk + diff state spoken — peel de ChangeReviewPatchA11yCard.

extension ChangeReviewPatchA11yCard {
    static func spokenRiskFlags(_ flags: [String]) -> String? {
        guard !flags.isEmpty else { return nil }
        return "alertas \(flags.joined(separator: ", "))"
    }

    static func spokenDiffState(expanded: Bool) -> String {
        expanded ? "diff expandido" : "diff recolhido"
    }
}
