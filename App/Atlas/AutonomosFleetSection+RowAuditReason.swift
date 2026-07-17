import SwiftUI
import AtlasCore

// Audit reason line — peel de AutonomosFleetSection+RowAudit.

extension AutonomosFleetSection {
    @ViewBuilder
    func agentAuditReason(_ agent: AtlasAutonomosFleetAgent) -> some View {
        if auditModeEnabled, let reason = agent.reason?.nonEmpty {
            Text(reason)
                .font(.caption2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
