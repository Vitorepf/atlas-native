import Foundation
import AtlasCore

/// State phrase — peel de AtlasCodeCommitRow+A11y.

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
            var parts = [title, "por \(author)", "fora da \(linha)"]
            if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
            return parts
        case .healed:
            return [title, "por \(author)", "curado"]
        case .onMain:
            return [title, "por \(author)", "na \(linha)"]
        case .history:
            return [title, "por \(author)", "história"]
        }
    }
}
