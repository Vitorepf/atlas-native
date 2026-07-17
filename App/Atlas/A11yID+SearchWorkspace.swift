import Foundation

// Search + Workspace A11yIDs — peel de A11yID+Home.

extension A11yID {
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

    static func searchResult(_ threadId: String) -> String { searchResultPrefix + threadId }
    static func workspaceThread(_ threadId: String) -> String { workspaceThreadPrefix + threadId }
}
