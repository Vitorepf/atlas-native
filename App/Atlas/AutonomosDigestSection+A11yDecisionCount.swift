import Foundation
import AtlasCore

// Decision count spoken — peel de AutonomosDigestSection+A11yCounts.

extension AutonomosDigestSectionA11y {
    static func appendDecisionCount(_ parts: inout [String], count: Int) {
        guard count > 0 else { return }
        parts.append("\(count) decisão\(count == 1 ? "" : "ões") pendente\(count == 1 ? "" : "s")")
    }
}
