import Foundation
import AtlasCore

// Schedule lead bind — peel de AutonomosDigestSection+A11yAggregate.

extension AutonomosDigestSectionA11y {
    static func spokenScheduleLeadParts(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool
    ) -> [String] {
        spokenScheduleLead(
            nextDigestAt: nextDigestAt,
            scheduleReason: scheduleReason,
            hasLast: hasLast
        )
    }
}
