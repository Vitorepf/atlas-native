import Foundation
import AtlasCore

// Healed branch spoken — peel de AtlasCodeCommitRow+A11yBranch.

extension AtlasCodeCommitRowA11yState {
    static func healedParts(title: String, author: String) -> [String] {
        [title, "por \(author)", "curado"]
    }
}
