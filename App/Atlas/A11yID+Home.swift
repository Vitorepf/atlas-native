import Foundation

// Home A11yIDs — peel de A11yID.swift (régua ≤100).
// Search/Workspace → A11yID+SearchWorkspace.swift

extension A11yID {
    static let homeScreen = "home-screen"
    static let topbarSearch = "topbar-search"
    static let topbarNew = "topbar-new"
    static let homeInputPill = "home-input-pill"
    static let homeWorkspaceChips = "home-workspace-chips"
    static let homeWorkspaceChipPrefix = "home-workspace-chip-"
    static let homeLoading = "home-loading"
    static let homeOffline = "home-offline"
    static let homeRetry = "home-retry"
    static let homeConversasSection = "home-conversas-section"
    static let homeOperacaoSection = "home-operacao-section"
    static let homeWorkspacesSection = "home-workspaces-section"
    static let homeConversasEntry = "home-conversas-entry"
    static let homeAutonomosEntry = "home-autonomos-entry"
    static let homeWorkspaceAll = "home-workspace-all"
    static let homeWorkspacePrefix = "home-workspace-"

    static func homeWorkspaceChip(_ key: String) -> String { homeWorkspaceChipPrefix + key }
    static func homeWorkspace(_ key: String) -> String { homeWorkspacePrefix + key }
}
