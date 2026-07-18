import Foundation
import AtlasCore

// Header spoken — peel de AutonomosAreaDetailSection+A11y.

extension AutonomosAreaDetailA11y {
    static func spokenHeader(area: AtlasAutonomosArea, isPaused: Bool?) -> String {
        var parts = [area.areaName]
        let focus = area.focus.trimmingCharacters(in: .whitespacesAndNewlines)
        if !focus.isEmpty { parts.append(focus) }
        parts.append("autonomia \(area.autonomyTier) de \(area.maxTierForArea)")
        parts.append(spokenPhase(area.loopStatus.phase))
        if let isPaused {
            parts.append(isPaused ? "pausada no runtime" : "ativa no runtime")
        }
        if !area.registered { parts.append("não registrada no servidor") }
        let objective = area.objective.trimmingCharacters(in: .whitespacesAndNewlines)
        if !objective.isEmpty { parts.append(objective) }
        return parts.joined(separator: ", ")
    }
}
