import Foundation
import AtlasCore

/// Operational spoken append — peel de AutonomosFleetSection+A11y.
/// Audit → AutonomosFleetSection+A11yAudit.swift
/// Runtime → AutonomosFleetSection+A11yDetails+Runtime.swift

extension AutonomosFleetSectionA11y {
    static func appendOperationalDetails(
        _ parts: inout [String],
        agent: AtlasAutonomosFleetAgent
    ) {
        appendRuntimeDetails(&parts, agent: agent)
        if let spent = agent.spentUsd { parts.append(String(format: "gasto US$ %.2f", spent)) }
        if !agent.desired { parts.append("não desejado") }
        if !agent.authorized { parts.append("não autorizado") }
    }
}
