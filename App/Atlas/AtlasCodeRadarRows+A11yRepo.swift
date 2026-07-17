import Foundation
import AtlasCore

// Repo spoken — peel de AtlasCodeRadarRows+A11y.
// Issues → AtlasCodeRadarRows+A11yRepoIssues.swift

extension AtlasCodeRadarRowsA11y {
    static func spokenRepo(
        name: String,
        folder: String?,
        showsFolder: Bool,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: String?
    ) -> String {
        var parts = [name]
        if showsFolder, let folder, !folder.isEmpty {
            parts.append("pasta \(folder)")
        }
        parts.append(contentsOf: spokenRepoIssues(issues: issues, trunk: trunk))
        if let age = AtlasCodeAge.short(from: lastCommitAt) {
            parts.append("último commit \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
