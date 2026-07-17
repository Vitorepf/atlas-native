import Foundation
import AtlasCore

// Contagens faladas — peel de AutonomosDigestSectionA11y.
// Delivered → AutonomosDigestSection+A11yDeliveredCount.swift
// Risk → AutonomosDigestSection+A11yRiskCount.swift
// Decision → AutonomosDigestSection+A11yDecisionCount.swift

extension AutonomosDigestSectionA11y {
    static func appendCounts(_ parts: inout [String], counts: AtlasAutonomosDigestCounts) {
        appendDeliveredCount(&parts, count: counts.delivered)
        appendRiskCount(&parts, count: counts.risks)
        appendDecisionCount(&parts, count: counts.pendingDecisions)
    }
}
