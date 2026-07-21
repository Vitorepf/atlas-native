import Foundation

// Diff state spoken — peel de ChangeReviewPatchA11yCard+Risk.

extension ChangeReviewPatchA11yCard {
    static func spokenDiffState(expanded: Bool) -> String {
        expanded ? "diff expandido" : "diff recolhido"
    }
}
