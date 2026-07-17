import Foundation

// Home workspace chip A11yIDs — peel de A11yID+Home.

extension A11yID {
    static let homeWorkspaceChips = "home-workspace-chips"
    static let homeWorkspaceChipPrefix = "home-workspace-chip-"
    static let homeWorkspaceAll = "home-workspace-all"
    static let homeWorkspacePrefix = "home-workspace-"

    static func homeWorkspaceChip(_ key: String) -> String { homeWorkspaceChipPrefix + key }
    static func homeWorkspace(_ key: String) -> String { homeWorkspacePrefix + key }
}
