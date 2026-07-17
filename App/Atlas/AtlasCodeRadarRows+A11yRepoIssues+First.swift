import Foundation
import AtlasCore

// First issue spoken — peel de AtlasCodeRadarRows+A11yRepoIssues.

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssueFirst(
        issues: [AtlasCodeIssue],
        trunk: String?
    ) -> [String] {
        guard let first = issues.first else { return [] }
        var parts = [first.headline(trunk: trunk)]
        if first.isSevere { parts.append("alta severidade") }
        return parts
    }
}
