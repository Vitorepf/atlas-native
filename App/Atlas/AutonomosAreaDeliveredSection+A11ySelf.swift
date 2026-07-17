import Foundation
import AtlasCore

/// Auto-construção spoken — peel de AutonomosAreaDeliveredSection+A11y.

enum AutonomosAreaDeliveredA11ySelf {
    static func spokenSection(total: Int, visible: Int) -> String {
        var parts = ["auto-construção, \(total) merge\(total == 1 ? "" : "s") comprovado\(total == 1 ? "" : "s") no ledger"]
        if visible < total { parts.append("mostrando \(visible) de \(total)") }
        parts.append("silêncio, você não foi necessário, só veto com recibo")
        return parts.joined(separator: ", ")
    }
}
