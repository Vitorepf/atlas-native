import Foundation
import AtlasCore

// Repo issues spoken — peel de AtlasCodeRadarRows+A11yRepo.
// First → AtlasCodeRadarRows+A11yRepoIssues+First.swift
// More → AtlasCodeRadarRows+A11yRepoIssues+More.swift

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssues(
        issues: [AtlasCodeIssue]?,
        trunk: String?
    ) -> [String] {
        guard let issues, !issues.isEmpty else { return [] }
        return spokenRepoIssueFirst(issues: issues, trunk: trunk)
            + spokenRepoIssueMore(issues: issues)
    }
}
