import Foundation
import AtlasCore

/// Last-digest headlines — peel de AutonomosDigestSection+A11yLast.

enum AutonomosDigestSectionA11yLastHeadlines {
    static func appendHeadlines(
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
    }
}
