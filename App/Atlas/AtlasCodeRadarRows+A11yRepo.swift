import Foundation
import AtlasCore

// Repo spoken — peel de AtlasCodeRadarRows+A11y.
// Issues → AtlasCodeRadarRows+A11yRepoIssues.swift
// Folder → AtlasCodeRadarRows+A11yRepo+Folder.swift
// CommitAge → AtlasCodeRadarRows+A11yRepo+CommitAge.swift

extension AtlasCodeRadarRowsA11y {
    static func spokenRepo(
        name: String,
        folder: String?,
        showsFolder: Bool,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: Int?
    ) -> String {
        var parts = [name]
        parts.append(contentsOf: spokenRepoFolder(folder: folder, showsFolder: showsFolder))
        parts.append(contentsOf: spokenRepoIssues(issues: issues, trunk: trunk))
        if let age = spokenRepoCommitAge(lastCommitAt: lastCommitAt) {
            parts.append(age)
        }
        return parts.joined(separator: ", ")
    }
}
