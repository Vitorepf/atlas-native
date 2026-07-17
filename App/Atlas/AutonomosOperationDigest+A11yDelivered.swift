import Foundation

// Delivered count spoken — peel de AutonomosOperationDigest+A11yCounts.

extension AutonomosOperationDigestA11y {
    static func spokenDeliveredCount(_ deliveredTotal: Int) -> String? {
        guard deliveredTotal > 0 else { return nil }
        return "\(deliveredTotal) entregue\(deliveredTotal == 1 ? "" : "s") comprovada\(deliveredTotal == 1 ? "" : "s")"
    }
}
