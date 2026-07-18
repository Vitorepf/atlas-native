import SwiftUI
import AtlasCore

// Card chrome — peel de AutonomosFleetSection+Row.

extension AutonomosFleetSection {
    @ViewBuilder
    func agentRowCardChrome<Content: View>(
        _ content: Content,
        agent: AtlasAutonomosFleetAgent,
        index: Int,
        compact: Bool
    ) -> some View {
        content
            .padding(12)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control)
            .autonomosFleetAgentA11y(
                agent: agent,
                index: index,
                total: fleet.agents.count,
                compact: compact,
                auditModeEnabled: auditModeEnabled
            )
    }
}
