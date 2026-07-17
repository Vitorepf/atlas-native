import Foundation

// Sheet lead spoken — peel de AutonomosTransferSheet+A11y.

extension AutonomosTransferSheetA11y {
    static func spokenSheet(areaName: String, hasPlacement: Bool) -> String {
        var parts = ["transferir missão", areaName]
        if hasPlacement {
            parts.append("lock verificado")
        } else {
            parts.append("sem lock publicado")
        }
        return parts.joined(separator: ", ")
    }
}
