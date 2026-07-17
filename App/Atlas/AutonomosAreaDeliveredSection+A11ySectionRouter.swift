import Foundation
import AtlasCore

// Section router spoken — peel de AutonomosAreaDeliveredSection+A11y.

extension AutonomosAreaDeliveredA11y {
    static func spokenSection(isSelf: Bool, total: Int, visible: Int) -> String {
        if isSelf {
            return AutonomosAreaDeliveredA11ySelf.spokenSection(total: total, visible: visible)
        }
        return spokenPeerSection(total: total, visible: visible)
    }
}
