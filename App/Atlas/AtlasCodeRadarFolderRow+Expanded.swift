import SwiftUI
import AtlasCore

/// Repos expandidos — peel de AtlasCodeFolderRow (régua ≤100).
/// Separator → AtlasCodeRadarFolderRow+Separator.swift
/// List → AtlasCodeRadarFolderRow+ExpandedList.swift

extension AtlasCodeFolderRow {
    @ViewBuilder var expandedRepos: some View {
        if isExpanded {
            expandedReposList
        }
    }
}
