import SwiftUI
import AtlasCore

// Placement tags — peel de AutonomosAreaDetailSection+Placement.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func placementTags(_ p: AtlasAutonomosRuntimePlacement) -> some View {
        HStack(spacing: 8) {
            if let host = p.host { AutonomosChrome.tag(host) }
            if let env = p.environment { AutonomosChrome.tag(env) }
            if let ws = p.workspace { AutonomosChrome.tag(ws) }
            if let repo = p.repository { AutonomosChrome.tag(repo) }
            if let branch = p.branch { AutonomosChrome.tag(branch) }
            if let ttl = p.leaseTTLSeconds { AutonomosChrome.tag("lease \(ttl)s") }
        }
        .accessibilityHidden(true)
    }
}
