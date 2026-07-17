import Foundation
import AtlasCore

// Row spoken — peel de AutonomosAreaDeliveredA11y.

extension AutonomosAreaDeliveredA11y {
    static func spokenRow(
        _ cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int,
        isSelf: Bool,
        opensGraph: Bool
    ) -> String {
        var parts = ["entrega \(index + 1) de \(visible)", "ciclo \(cycle.cycleIndex)"]
        if cycle.mergePerformed, let hash = cycle.mergeHash.nonEmpty {
            parts.append("merge comprovado \(String(hash.prefix(8)))")
        } else {
            parts.append("merge não publicado")
        }
        if let at = cycle.recordedAt.nonEmpty { parts.append("em \(at)") }
        if isSelf { parts.append("abre recibo de auto-construção") }
        else if opensGraph { parts.append("abre merge no grafo") }
        return parts.joined(separator: ", ")
    }
}
