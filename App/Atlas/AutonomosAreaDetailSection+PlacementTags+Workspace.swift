import SwiftUI
import AtlasCore

// Placement workspace tags — peel de AutonomosAreaDetailSection+PlacementTags.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func placementWorkspaceTags(_ p: AtlasAutonomosRuntimePlacement) -> some View {
        if let ws = p.workspace { AutonomosChrome.tag(ws) }
        if let repo = p.repository { AutonomosChrome.tag(repo) }
        if let branch = p.branch { AutonomosChrome.tag(branch) }
        if let ttl = p.leaseTTLSeconds { AutonomosChrome.tag("lease \(ttl)s") }
    }
}
