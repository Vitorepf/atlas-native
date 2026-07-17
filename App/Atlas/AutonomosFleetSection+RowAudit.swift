import SwiftUI
import AtlasCore

// Audit tags — peel de AutonomosFleetSection+RowTags.
// Reason → AutonomosFleetSection+RowAuditReason.swift

extension AutonomosFleetSection {
    @ViewBuilder
    func agentAuditTags(_ agent: AtlasAutonomosFleetAgent) -> some View {
        if auditModeEnabled {
            HStack(spacing: 6) {
                AutonomosChrome.tag(agent.account)
                AutonomosChrome.tag(agent.kind)
                if let ttl = agent.ttlRemainingSeconds { AutonomosChrome.tag("ttl \(ttl)s") }
                if let budget = agent.budgetLimitUsd { AutonomosChrome.tag(String(format: "limite %.2f", budget)) }
                if let target = agent.targetRef?.nonEmpty { AutonomosChrome.tag(target) }
            }
            .accessibilityHidden(true)
            agentAuditReason(agent)
        }
    }
}
