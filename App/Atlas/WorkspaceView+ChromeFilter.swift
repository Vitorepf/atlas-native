import SwiftUI
import AtlasCore

// Filtro de área — peel de WorkspaceView+Chrome (régua ≤100).
// New pill → WorkspaceView+ChromeNewPill.swift
// Chip → WorkspaceView+ChromeFilterChip.swift

extension WorkspaceView {
    var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            areaFilterChipRow
        }
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.workspaceAreaFilter)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
    }
}
