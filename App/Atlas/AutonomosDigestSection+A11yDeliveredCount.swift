import Foundation
import AtlasCore

// Delivered count spoken — peel de AutonomosDigestSection+A11yCounts.

extension AutonomosDigestSectionA11y {
    static func appendDeliveredCount(_ parts: inout [String], count: Int) {
        guard count > 0 else { return }
        parts.append("\(count) entrega\(count == 1 ? "" : "s") comprovada\(count == 1 ? "" : "s")")
    }
}
