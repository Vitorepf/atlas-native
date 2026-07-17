import Foundation

// Composer workspace A11yIDs — peel de A11yID+Composer.

extension A11yID {
    static let workspaceSheet = "composer-workspace-sheet"
    static let workspaceRowPrefix = "composer-workspace-row-"
    static func workspaceRow(_ key: String) -> String { workspaceRowPrefix + key }
}
