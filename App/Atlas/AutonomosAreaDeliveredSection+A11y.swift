import Foundation
import AtlasCore

/// Spoken labels das entregas comprovadas — peel de AutonomosAreaDeliveredSection (CICLO C).
/// Merge só quando `mergePerformed` e hash publicados; nunca «melhorou» fabricado.

enum AutonomosAreaDeliveredA11y {
    static let visibleCap = 3

    static func spokenSection(isSelf: Bool, total: Int, visible: Int) -> String {
        if isSelf {
            var parts = ["auto-construção, \(total) merge\(total == 1 ? "" : "s") comprovado\(total == 1 ? "" : "s") no ledger"]
            if visible < total { parts.append("mostrando \(visible) de \(total)") }
            parts.append("silêncio, você não foi necessário, só veto com recibo")
            return parts.joined(separator: ", ")
        }
        if visible < total {
            return "entregas comprovadas, \(visible) de \(total) merges recentes"
        }
        return "entregas comprovadas, \(total) merge\(total == 1 ? "" : "s")"
    }

    static func spokenEmptySelf() -> String {
        "auto-construção, aguardando ledger, nenhuma entrega comprovada neste recorte"
    }

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
