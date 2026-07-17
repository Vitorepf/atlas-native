import Foundation

// Home workspace row A11yID — peel de A11yID+HomeWorkspace.

extension A11yID {
    static let homeWorkspacePrefix = "home-workspace-"
    static func homeWorkspace(_ key: String) -> String { homeWorkspacePrefix + key }
}
