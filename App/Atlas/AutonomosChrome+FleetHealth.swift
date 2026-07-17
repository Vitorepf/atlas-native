import SwiftUI
import AtlasCore

enum AutonomosFleetHealth {
    static func isQuiet(fleet: AtlasAutonomosFleetResponse, incidentPresent: Bool) -> Bool {
        !incidentPresent
            && !fleet.agents.isEmpty
            && fleet.agents.allSatisfy { $0.alive && $0.desired && $0.authorized }
    }

    static func agentNeedsAttention(_ agent: AtlasAutonomosFleetAgent) -> Bool {
        !agent.alive || !agent.desired || !agent.authorized
    }
}
