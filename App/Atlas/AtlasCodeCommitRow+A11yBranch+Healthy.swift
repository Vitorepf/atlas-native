import Foundation
import AtlasCore

// Healed/onMain branch — peel de AtlasCodeCommitRow+A11yBranch.

extension AtlasCodeCommitRowA11yState {
    static func branchPartsHealthy(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String]? {
        switch state {
        case .healed:
            return healedParts(title: title, author: author)
        case .onMain:
            return onMainParts(title: title, author: author, linha: linha)
        default:
            return nil
        }
    }
}
