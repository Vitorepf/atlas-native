import Foundation
import AtlasCore

// Risk count spoken — peel de AutonomosDigestSection+A11yCounts.

extension AutonomosDigestSectionA11y {
    static func appendRiskCount(_ parts: inout [String], count: Int) {
        guard count > 0 else { return }
        parts.append("\(count) risco\(count == 1 ? "" : "s")")
    }
}
