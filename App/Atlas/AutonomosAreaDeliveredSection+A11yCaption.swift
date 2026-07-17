import Foundation
import AtlasCore

/// Caption + hints — peel de AutonomosAreaDeliveredSection+A11y.

extension AutonomosAreaDeliveredA11y {
    static func spokenRowHint(isSelf: Bool) -> String {
        isSelf ? "abre recibo com regra e prova do ciclo" : "abre o commit no grafo de código"
    }

    static func sectionCaption(isSelf: Bool, total: Int, visible: Int) -> String {
        if isSelf {
            return visible < total
                ? "AUTO-CONSTRUÇÃO · \(visible) DE \(total) NO LEDGER"
                : "AUTO-CONSTRUÇÃO · \(total) NO LEDGER"
        }
        return visible < total
            ? "ENTREGAS COMPROVADAS · \(visible) DE \(total)"
            : "ENTREGAS COMPROVADAS · \(total)"
    }
}
