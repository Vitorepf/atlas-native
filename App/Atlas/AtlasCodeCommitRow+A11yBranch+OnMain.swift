import Foundation
import AtlasCore

// On-main branch spoken — peel de AtlasCodeCommitRow+A11yBranch.

extension AtlasCodeCommitRowA11yState {
    static func onMainParts(title: String, author: String, linha: String) -> [String] {
        [title, "por \(author)", "na \(linha)"]
    }
}
