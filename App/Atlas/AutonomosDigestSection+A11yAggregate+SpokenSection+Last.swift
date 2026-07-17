import Foundation
import AtlasCore

// Last digest append — peel de AutonomosDigestSection+A11yAggregate+SpokenSection.

extension AutonomosDigestSectionA11y {
    static func spokenSectionLastParts(
        parts: inout [String],
        windowCaption: String?,
        counts: AtlasAutonomosDigestCounts,
        mergeHash: String?,
        riskHeadline: String?,
        decisionTitle: String?
    ) {
        spokenLastBody(
            parts: &parts,
            windowCaption: windowCaption,
            counts: counts,
            mergeHash: mergeHash,
            riskHeadline: riskHeadline,
            decisionTitle: decisionTitle
        )
    }
}
