import SwiftUI
import AtlasCore

// Row inner stack — peel de AutonomosFleetSection+Row.

extension AutonomosFleetSection {
    @ViewBuilder
    func agentRowInnerStack(_ agent: AtlasAutonomosFleetAgent, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            agentRowHeader(agent)
            agentCompactTags(agent, compact: compact)
            agentAuditTags(agent)
        }
    }
}
