import Foundation
import AtlasCore

// Empty schedule reason — peel de AutonomosDigestSection+A11ySchedule.

extension AutonomosDigestSectionA11y {
    static func spokenScheduleReasonParts(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool
    ) -> [String] {
        guard !hasLast else { return [] }
        var parts: [String] = []
        if let reason = scheduleReason?.nonEmpty {
            parts.append(reason)
        } else if nextDigestAt?.nonEmpty == nil {
            parts.append("sem agenda publicada")
        }
        return parts
    }
}
