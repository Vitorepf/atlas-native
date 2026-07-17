import Foundation

// Delivered count append — peel de AutonomosOperationDigest+A11yCounts.

extension AutonomosOperationDigestA11y {
    static func spokenCountsDelivered(_ parts: inout [String], deliveredTotal: Int) {
        if let delivered = spokenDeliveredCount(deliveredTotal) {
            parts.append(delivered)
        }
    }
}
