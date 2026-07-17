import Foundation
import AtlasCore

/// Uptime/process spoken — peel de AutonomosFleetSection+A11yDetails.

extension AutonomosFleetSectionA11y {
    static func appendRuntimeDetails(
        _ parts: inout [String],
        agent: AtlasAutonomosFleetAgent
    ) {
        if let up = agent.uptimeSeconds { parts.append("ativo há \(AutonomosChrome.uptime(up))") }
        if !agent.pids.isEmpty {
            parts.append("\(agent.pids.count) processo\(agent.pids.count == 1 ? "" : "s")")
        }
    }
}
