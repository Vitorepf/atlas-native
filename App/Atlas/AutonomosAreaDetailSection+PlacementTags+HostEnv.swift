import SwiftUI
import AtlasCore

// Placement host/env tags — peel de AutonomosAreaDetailSection+PlacementTags.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func placementHostEnvTags(_ p: AtlasAutonomosRuntimePlacement) -> some View {
        if let host = p.host { AutonomosChrome.tag(host) }
        if let env = p.environment { AutonomosChrome.tag(env) }
    }
}
