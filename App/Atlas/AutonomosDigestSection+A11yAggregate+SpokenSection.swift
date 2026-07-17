import Foundation
import AtlasCore

// spokenSection assembly — peel de AutonomosDigestSection+A11yAggregate.
// Schedule → AutonomosDigestSection+A11yAggregate+SpokenSection+Schedule.swift
// Last → AutonomosDigestSection+A11yAggregate+SpokenSection+Last.swift

extension AutonomosDigestSectionA11y {
    static func spokenSection(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool,
        windowCaption: String?,
        counts: AtlasAutonomosDigestCounts,
        mergeHash: String?,
        riskHeadline: String?,
        decisionTitle: String?
    ) -> String {
        var parts = spokenSectionScheduleParts(
            nextDigestAt: nextDigestAt,
            scheduleReason: scheduleReason,
            hasLast: hasLast
        )
        if hasLast {
            spokenSectionLastParts(
                parts: &parts,
                windowCaption: windowCaption,
                counts: counts,
                mergeHash: mergeHash,
                riskHeadline: riskHeadline,
                decisionTitle: decisionTitle
            )
        }
        return parts.joined(separator: ", ")
    }
}
