import Foundation
import AtlasCore

// History branch spoken — peel de AtlasCodeCommitRow+A11yBranch.

extension AtlasCodeCommitRowA11yState {
    static func historyParts(title: String, author: String) -> [String] {
        [title, "por \(author)", "história"]
    }
}
