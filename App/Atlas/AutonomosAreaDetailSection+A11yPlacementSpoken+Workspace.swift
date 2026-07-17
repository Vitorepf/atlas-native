import Foundation
import AtlasCore

// Placement workspace spoken — peel de AutonomosAreaDetailSection+A11yPlacementSpoken.

extension AutonomosAreaDetailA11y {
    static func spokenPlacementWorkspace(_ placement: AtlasAutonomosRuntimePlacement) -> [String] {
        var parts: [String] = []
        if let ws = placement.workspace, !ws.isEmpty { parts.append("workspace \(ws)") }
        if let repo = placement.repository, !repo.isEmpty { parts.append("repositório \(repo)") }
        if let branch = placement.branch, !branch.isEmpty { parts.append("branch \(branch)") }
        if let ttl = placement.leaseTTLSeconds { parts.append("lease \(ttl) segundos") }
        return parts
    }
}
