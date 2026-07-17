import AtlasCore
import SwiftUI

// Linha de pasta do radar — peel de AtlasCodeRadarRows.
// Header → +Header · Expandidos → +Expanded · spoken → FolderRow+A11y.
// Count → AtlasCodeRadarFolderRow+Count.swift
// Toggle → AtlasCodeRadarFolderRow+Toggle.swift
struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            folderToggleButton
            expandedRepos
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}
