import Foundation

// Workspace A11yIDs — peel de A11yID+SearchWorkspace.

extension A11yID {
    static let workspaceScreen = "workspace-screen"
    static let workspaceEmpty = "workspace-empty"
    static let workspaceLoading = "workspace-loading"
    static let workspaceOffline = "workspace-offline"
    static let workspaceRetry = "workspace-retry"
    static let workspaceThreadsCaption = "workspace-threads-caption"
    static let workspaceThreadPrefix = "workspace-thread-"
    static let workspaceAreaFilter = "workspace-area-filter"
    static let workspaceNewPill = "workspace-new-pill"

    static func workspaceThread(_ threadId: String) -> String { workspaceThreadPrefix + threadId }
}
