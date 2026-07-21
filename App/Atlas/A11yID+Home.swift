import Foundation

// Home A11yIDs — peel de A11yID.swift (régua ≤100).
// Sections → A11yID+HomeSections.swift
// Workspace → A11yID+HomeWorkspace.swift
// Search/Workspace → A11yID+SearchWorkspace.swift

extension A11yID {
    static let topbarSearch = "topbar-search"
    static let topbarProfile = "topbar-profile"
    static let profileSheet = "profile-sheet"
    static let profileAuditToggle = "profile-audit-toggle"
    static let homeAddWorkspace = "home-add-workspace"
    static let workspacePickerSheet = "workspace-picker-sheet"
    static let workspacePickerRowPrefix = "workspace-picker-"
    static func workspacePickerRow(_ slug: String) -> String { workspacePickerRowPrefix + slug }
    static let workspacePickerNoRepo = "workspace-picker-no-repo"
    static let homeInputPill = "home-input-pill"
    static let homeLoading = "home-loading"
    static let homeOffline = "home-offline"
    static let homeRetry = "home-retry"
}
