import Foundation
import AtlasCore

// Placement spoken — peel de AutonomosAreaDetailSection+A11yPlacement.
// HostEnv → AutonomosAreaDetailSection+A11yPlacementSpoken+HostEnv.swift
// Workspace → AutonomosAreaDetailSection+A11yPlacementSpoken+Workspace.swift

extension AutonomosAreaDetailA11y {
    static func spokenPlacement(_ placement: AtlasAutonomosRuntimePlacement) -> String {
        (
            ["onde está rodando"]
            + spokenPlacementHostEnv(placement)
            + spokenPlacementWorkspace(placement)
        ).joined(separator: ", ")
    }
}
