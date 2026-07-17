import Foundation
import AtlasCore

/// Diff toggle / risk spoken — peel de ChangeReviewDiffSection+A11y.

enum ChangeReviewPatchA11yToggle {
    static func spokenDiffToggle(expanded: Bool) -> String {
        expanded ? "fechar diff do patch" : "ver diff do patch"
    }

    static func spokenRiskFlags(_ flags: [String]) -> String {
        "alertas de risco, \(flags.joined(separator: ", "))"
    }
}
