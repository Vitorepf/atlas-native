import Foundation
import AtlasCore

/// Spoken labels da frota — peel de AutonomosFleetSection (CICLO C).
/// Details → AutonomosFleetSection+A11yDetails.swift
/// Agent → AutonomosFleetSection+A11yAgent.swift

enum AutonomosFleetSectionA11y {
    static func spokenSection(
        agentCount: Int,
        activeCount: Int,
        incidentPresent: Bool,
        isQuiet: Bool
    ) -> String {
        var parts = [incidentPresent ? "frota requer atenção" : "frota"]
        parts.append("\(agentCount) agente\(agentCount == 1 ? "" : "s")")
        parts.append("\(activeCount) ativo\(activeCount == 1 ? "" : "s")")
        if isQuiet { parts.append("todos vivos, desejados e autorizados") }
        return parts.joined(separator: ", ")
    }
}
