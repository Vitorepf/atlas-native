import Foundation

/// Headlines spoken — peel de AutonomosOperationDigest+A11y.
/// Display → AutonomosOperationDigest+A11yDisplay.swift
/// Findings → AutonomosOperationDigest+A11yFindingsRisk.swift

extension AutonomosOperationDigestA11y {
    static func spokenHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return "incidente aguarda sua decisão; frota segue por exceção" }
        if delivered > 0 && pending == 0 {
            return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s"), nada pendente"
        }
        if delivered > 0 {
            return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) na fila, segue sem portão"
        }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila, nenhuma entrega comprovada nesta janela"
    }
}
