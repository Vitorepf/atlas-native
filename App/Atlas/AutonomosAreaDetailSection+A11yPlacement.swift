import Foundation
import AtlasCore

/// Placement / sistemas / fase — peel de AutonomosAreaDetailSection+A11y.

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

    static func spokenOwnedSystems(_ systems: [String]) -> String {
        "sistemas sob responsabilidade, \(systems.joined(separator: ", "))"
    }

    static func spokenMetric(label: String, value: Int?) -> String {
        guard let value else { return "\(label) não publicado" }
        return "\(value) \(label)"
    }

    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        switch phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
