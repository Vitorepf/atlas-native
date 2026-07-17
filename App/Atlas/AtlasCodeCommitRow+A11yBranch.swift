import Foundation
import AtlasCore

// Healed/onMain/history spoken — peel de AtlasCodeCommitRow+A11yState.
// Violating → AtlasCodeCommitRow+A11yViolating.swift

extension AtlasCodeCommitRowA11yState {
    static func branchParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String] {
        switch state {
        case .healed:
            return [title, "por \(author)", "curado"]
        case .onMain:
            return [title, "por \(author)", "na \(linha)"]
        case .history:
            return [title, "por \(author)", "história"]
        case .violating:
            return []
        }
    }
}
