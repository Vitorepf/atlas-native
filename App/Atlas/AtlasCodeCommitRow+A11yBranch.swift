import Foundation
import AtlasCore

// Healed/onMain/history spoken — peel de AtlasCodeCommitRow+A11yState.
// Violating → AtlasCodeCommitRow+A11yViolating.swift
// Healed → AtlasCodeCommitRow+A11yBranch+Healed.swift
// OnMain → AtlasCodeCommitRow+A11yBranch+OnMain.swift
// History → AtlasCodeCommitRow+A11yBranch+History.swift
// Healthy → AtlasCodeCommitRow+A11yBranch+Healthy.swift

extension AtlasCodeCommitRowA11yState {
    static func branchParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String] {
        if let healthy = branchPartsHealthy(title: title, author: author, linha: linha, state: state) {
            return healthy
        }
        switch state {
        case .history:
            return historyParts(title: title, author: author)
        case .violating:
            return []
        default:
            return []
        }
    }
}
