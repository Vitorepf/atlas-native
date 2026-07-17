import Foundation
import AtlasCore

/// Audit spoken append — peel de AutonomosFleetSection+A11yDetails.

extension AutonomosFleetSectionA11y {
    static func appendAuditDetails(
        _ parts: inout [String],
        agent: AtlasAutonomosFleetAgent
    ) {
        parts.append("conta \(agent.account)")
        parts.append(agent.kind)
        if let ttl = agent.ttlRemainingSeconds { parts.append("ttl \(ttl) segundos") }
        if let budget = agent.budgetLimitUsd { parts.append(String(format: "limite US$ %.2f", budget)) }
        if let target = agent.targetRef?.nonEmpty { parts.append("alvo \(target)") }
        if let reason = agent.reason?.nonEmpty { parts.append(reason) }
    }
}
