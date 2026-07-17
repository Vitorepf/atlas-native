import SwiftUI
import AtlasCore

// Placement tags — peel de AutonomosAreaDetailSection+Placement.
// HostEnv → AutonomosAreaDetailSection+PlacementTags+HostEnv.swift
// Workspace → AutonomosAreaDetailSection+PlacementTags+Workspace.swift

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func placementTags(_ p: AtlasAutonomosRuntimePlacement) -> some View {
        HStack(spacing: 8) {
            placementHostEnvTags(p)
            placementWorkspaceTags(p)
        }
        .accessibilityHidden(true)
    }
}
