import Foundation
import AtlasCore

// Schedule lead spoken — peel de AutonomosDigestSection+A11y.

extension AutonomosDigestSectionA11y {
    static func spokenScheduleLead(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool
    ) -> [String] {
        var parts: [String] = []
        if let next = nextDigestAt?.nonEmpty {
            parts.append("próximo resumo, agendado para \(next)")
        } else {
            parts.append("resumo governado")
        }
        if !hasLast {
            if let reason = scheduleReason?.nonEmpty {
                parts.append(reason)
            } else if nextDigestAt?.nonEmpty == nil {
                parts.append("sem agenda publicada")
            }
        }
        return parts
    }
}
