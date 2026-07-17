import Foundation
import AtlasCore

// Contagens faladas — peel de AutonomosDigestSectionA11y.

extension AutonomosDigestSectionA11y {
    static func appendCounts(_ parts: inout [String], counts: AtlasAutonomosDigestCounts) {
        if counts.delivered > 0 {
            parts.append("\(counts.delivered) entrega\(counts.delivered == 1 ? "" : "s") comprovada\(counts.delivered == 1 ? "" : "s")")
        }
        if counts.risks > 0 {
            parts.append("\(counts.risks) risco\(counts.risks == 1 ? "" : "s")")
        }
        if counts.pendingDecisions > 0 {
            parts.append("\(counts.pendingDecisions) decisão\(counts.pendingDecisions == 1 ? "" : "ões") pendente\(counts.pendingDecisions == 1 ? "" : "s")")
        }
    }
}
