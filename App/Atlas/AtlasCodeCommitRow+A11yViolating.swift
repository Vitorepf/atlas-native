import Foundation
import AtlasCore

// Violating state spoken — peel de AtlasCodeCommitRow+A11yState.

extension AtlasCodeCommitRowA11yState {
    static func violatingParts(
        title: String,
        author: String,
        linha: String,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        var parts = [title, "por \(author)", "fora da \(linha)"]
        if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
        return parts
    }
}
