import Foundation
import AtlasCore

// Aggregate spoken — peel de AutonomosDigestSection+A11y.
// LastBody → AutonomosDigestSection+A11yAggregate+LastBody.swift

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
        var parts = spokenScheduleLead(
            nextDigestAt: nextDigestAt,
            scheduleReason: scheduleReason,
            hasLast: hasLast
        )
        if hasLast {
            spokenLastBody(
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
