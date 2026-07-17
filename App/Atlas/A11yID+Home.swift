import Foundation

// Home / Search / Workspace A11yIDs — peel de A11yID.swift (régua ≤100).

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

    static let searchScreen = "search-screen"
    static let searchField = "search-field"
    static let searchClear = "search-clear"
    static let searchRecentCaption = "search-recent-caption"
    static let searchResultsCaption = "search-results-caption"
    static let searchEmpty = "search-empty"
    static let searchLoading = "search-loading"
    static let searchOffline = "search-offline"
    static let searchResultPrefix = "search-result-"

    static let workspaceScreen = "workspace-screen"
    static let workspaceEmpty = "workspace-empty"
    static let workspaceLoading = "workspace-loading"
    static let workspaceOffline = "workspace-offline"
    static let workspaceRetry = "workspace-retry"
    static let workspaceThreadsCaption = "workspace-threads-caption"
    static let workspaceThreadPrefix = "workspace-thread-"
    static let workspaceAreaFilter = "workspace-area-filter"
    static let workspaceNewPill = "workspace-new-pill"

    static func homeWorkspaceChip(_ key: String) -> String { homeWorkspaceChipPrefix + key }
    static func homeWorkspace(_ key: String) -> String { homeWorkspacePrefix + key }
    static func searchResult(_ threadId: String) -> String { searchResultPrefix + threadId }
    static func workspaceThread(_ threadId: String) -> String { workspaceThreadPrefix + threadId }
}
