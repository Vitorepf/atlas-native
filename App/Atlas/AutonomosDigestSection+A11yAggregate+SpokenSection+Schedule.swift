import Foundation
import AtlasCore

// Schedule lead — peel de AutonomosDigestSection+A11yAggregate+SpokenSection.

extension AutonomosDigestSectionA11y {
    static func spokenSectionScheduleParts(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool
    ) -> [String] {
        spokenScheduleLeadParts(
            nextDigestAt: nextDigestAt,
            scheduleReason: scheduleReason,
            hasLast: hasLast
        )
    }
}
