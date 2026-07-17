import Foundation
import AtlasCore

// Open-action spoken — peel de AutonomosAreaDeliveredSection+A11yRow.

extension AutonomosAreaDeliveredA11y {
    static func spokenRowOpenParts(
        _ cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int,
        isSelf: Bool,
        opensGraph: Bool
    ) -> [String] {
        var parts = ["entrega \(index + 1) de \(visible)", "ciclo \(cycle.cycleIndex)"]
        parts.append(contentsOf: spokenRowMergeParts(cycle))
        if let at = cycle.recordedAt.nonEmpty { parts.append("em \(at)") }
        if isSelf { parts.append("abre recibo de auto-construção") }
        else if opensGraph { parts.append("abre merge no grafo") }
        return parts
    }
}
