import Foundation
import AtlasCore

// Repo issues spoken — peel de AtlasCodeRadarRows+A11yRepo.

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssues(
        issues: [AtlasCodeIssue]?,
        trunk: String?
    ) -> [String] {
        var parts: [String] = []
        if let issues, !issues.isEmpty {
            if let first = issues.first {
                parts.append(first.headline(trunk: trunk))
                if first.isSevere { parts.append("alta severidade") }
            }
            if issues.count > 1 {
                let more = issues.count - 1
                parts.append("mais \(more) desvio\(more == 1 ? "" : "s")")
            }
        }
        return parts
    }
}
