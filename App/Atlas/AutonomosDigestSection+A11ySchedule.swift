import Foundation
import AtlasCore

// Schedule lead spoken — peel de AutonomosDigestSection+A11y.
// Next → AutonomosDigestSection+A11yScheduleNext.swift
// Reason → AutonomosDigestSection+A11yScheduleReason.swift

extension AutonomosDigestSectionA11y {
    static func spokenScheduleLead(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool
    ) -> [String] {
        var parts = [spokenScheduleNextLead(nextDigestAt)]
        parts.append(contentsOf: spokenScheduleReasonParts(
            nextDigestAt: nextDigestAt,
            scheduleReason: scheduleReason,
            hasLast: hasLast
        ))
        return parts
    }
}
