import Foundation
import AtlasCore

// Placement host/env spoken — peel de AutonomosAreaDetailSection+A11yPlacementSpoken.

extension AutonomosAreaDetailA11y {
    static func spokenPlacementHostEnv(_ placement: AtlasAutonomosRuntimePlacement) -> [String] {
        var parts: [String] = []
        if let host = placement.host, !host.isEmpty { parts.append("host \(host)") }
        if let env = placement.environment, !env.isEmpty { parts.append("ambiente \(env)") }
        return parts
    }
}
