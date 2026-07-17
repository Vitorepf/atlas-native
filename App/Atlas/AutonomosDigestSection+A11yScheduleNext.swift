import Foundation
import AtlasCore

// Next digest lead — peel de AutonomosDigestSection+A11ySchedule.

extension AutonomosDigestSectionA11y {
    static func spokenScheduleNextLead(_ nextDigestAt: String?) -> String {
        if let next = nextDigestAt?.nonEmpty {
            return "próximo resumo, agendado para \(next)"
        }
        return "resumo governado"
    }
}
