import Foundation
import AtlasCore

// Last digest body — peel de AutonomosDigestSection+A11yAggregate.

extension AutonomosDigestSectionA11y {
    static func spokenLastBody(
        parts: inout [String],
        windowCaption: String?,
        counts: AtlasAutonomosDigestCounts,
        mergeHash: String?,
        riskHeadline: String?,
        decisionTitle: String?
    ) {
        AutonomosDigestSectionA11yLast.appendLastBody(
            &parts,
            windowCaption: windowCaption,
            counts: counts,
            mergeHash: mergeHash,
            riskHeadline: riskHeadline,
            decisionTitle: decisionTitle
        )
    }
}
