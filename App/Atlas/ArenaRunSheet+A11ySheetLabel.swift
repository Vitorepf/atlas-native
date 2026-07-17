import Foundation
import AtlasCore

// Sheet spoken body — peel de ArenaRunSheet+A11ySheet.

extension ArenaRunSheet {
    func spokenSheetLabel() -> String {
        var parts = ["rodar medição Arena"]
        if engines.isEmpty {
            parts.append("nenhum motor publicado")
        } else {
            parts.append("\(engines.count) motor\(engines.count == 1 ? "" : "es")")
        }
        let suites = installedSuites.count
        if suites == 0 {
            parts.append("nenhuma suite com adapter")
        } else {
            parts.append("\(suites) suite\(suites == 1 ? "" : "s") instalada\(suites == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }

    func spokenSheetHint() -> String {
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    }
}
