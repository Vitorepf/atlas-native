import Foundation
import AtlasCore

// Extra issues count — peel de AtlasCodeRadarRows+A11yRepoIssues.

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssueMore(issues: [AtlasCodeIssue]) -> [String] {
        guard issues.count > 1 else { return [] }
        let more = issues.count - 1
        return ["mais \(more) desvio\(more == 1 ? "" : "s")"]
    }
}
