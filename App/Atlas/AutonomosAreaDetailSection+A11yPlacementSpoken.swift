import Foundation
import AtlasCore

// Placement spoken — peel de AutonomosAreaDetailSection+A11yPlacement.

extension AutonomosAreaDetailA11y {
    static func spokenPlacement(_ placement: AtlasAutonomosRuntimePlacement) -> String {
        var parts = ["onde está rodando"]
        if let host = placement.host, !host.isEmpty { parts.append("host \(host)") }
        if let env = placement.environment, !env.isEmpty { parts.append("ambiente \(env)") }
        if let ws = placement.workspace, !ws.isEmpty { parts.append("workspace \(ws)") }
        if let repo = placement.repository, !repo.isEmpty { parts.append("repositório \(repo)") }
        if let branch = placement.branch, !branch.isEmpty { parts.append("branch \(branch)") }
        if let ttl = placement.leaseTTLSeconds { parts.append("lease \(ttl) segundos") }
        return parts.joined(separator: ", ")
    }
}
