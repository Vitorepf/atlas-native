import Foundation
import AtlasCore

/// State phrase — peel de AtlasCodeCommitRow+A11y.
// Violating → AtlasCodeCommitRow+A11yViolating.swift · Branch → +A11yBranch.swift

enum AtlasCodeCommitRowA11yState {
    static func stateParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        switch state {
        case .violating:
            return violatingParts(
                title: title,
                author: author,
                linha: linha,
                ruleId: ruleId,
                trunk: trunk
            )
        default:
            return branchParts(title: title, author: author, linha: linha, state: state)
        }
    }
}
