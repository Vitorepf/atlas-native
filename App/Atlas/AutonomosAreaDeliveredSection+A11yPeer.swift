import Foundation

// Peer-area delivered spoken — peel de AutonomosAreaDeliveredSection+A11y.

extension AutonomosAreaDeliveredA11y {
    static func spokenPeerSection(total: Int, visible: Int) -> String {
        if visible < total {
            return "entregas comprovadas, \(visible) de \(total) merges recentes"
        }
        return "entregas comprovadas, \(total) merge\(total == 1 ? "" : "s")"
    }
}
