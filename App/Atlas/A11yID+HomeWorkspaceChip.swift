import Foundation

// Home workspace chip A11yID — peel de A11yID+HomeWorkspace.

extension A11yID {
    static let homeWorkspaceChips = "home-workspace-chips"
    static let homeWorkspaceChipPrefix = "home-workspace-chip-"
    static let homeWorkspaceAll = "home-workspace-all"
    static func homeWorkspaceChip(_ key: String) -> String { homeWorkspaceChipPrefix + key }
}
