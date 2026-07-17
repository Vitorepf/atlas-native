import Foundation

/// Headlines display/spoken — peel de AutonomosOperationDigest+A11y.

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

    static func spokenFindings(_ findings: [String: Int]) -> String {
        let pairs = findings.sorted { $0.value > $1.value }.map { "\($0.key) \($0.value)" }
        return "achados por risco, \(pairs.joined(separator: ", "))"
    }

    static func displayHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return "Um incidente aguarda sua decisão; o resto da frota segue por exceção." }
        if delivered > 0 && pending == 0 {
            return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s") — silêncio; nada pendente para você."
        }
        if delivered > 0 {
            return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) ainda na fila — segue sem portão; só exceção te chama."
        }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila; nenhuma entrega comprovada ainda nesta janela."
    }
}
