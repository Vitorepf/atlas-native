import Foundation
import AtlasCore

/// Last-digest spoken body — peel de AutonomosDigestSection+A11y.
/// Headlines → AutonomosDigestSection+A11yLast+Headlines.swift

enum AutonomosDigestSectionA11yLast {
    static func appendLastBody(
        _ parts: inout [String],
        windowCaption: String?,
        counts: AtlasAutonomosDigestCounts,
        mergeHash: String?,
        riskHeadline: String?,
        decisionTitle: String?
    ) {
        AutonomosDigestSectionA11yLastHeadlines.appendHeadlines(
            &parts,
            windowCaption: windowCaption,
            counts: counts,
            mergeHash: mergeHash,
            riskHeadline: riskHeadline,
            decisionTitle: decisionTitle
        )
        if counts.delivered > 0 && counts.risks == 0 && counts.pendingDecisions == 0 {
            parts.append("silêncio, segue sem portão")
        }
    }
}
