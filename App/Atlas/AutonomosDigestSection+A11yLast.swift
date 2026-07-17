import Foundation
import AtlasCore

/// Last-digest spoken body — peel de AutonomosDigestSection+A11y.

enum AutonomosDigestSectionA11yLast {
    static func appendLastBody(
        _ parts: inout [String],
        windowCaption: String?,
        counts: AtlasAutonomosDigestCounts,
        mergeHash: String?,
        riskHeadline: String?,
        decisionTitle: String?
    ) {
        if let windowCaption { parts.append(windowCaption) }
        AutonomosDigestSectionA11y.appendCounts(&parts, counts: counts)
        if let mergeHash { parts.append("merge \(mergeHash)") }
        if let riskHeadline { parts.append(riskHeadline) }
        if let decisionTitle { parts.append(decisionTitle) }
        if counts.delivered > 0 && counts.risks == 0 && counts.pendingDecisions == 0 {
            parts.append("silêncio, segue sem portão")
        }
    }
}
