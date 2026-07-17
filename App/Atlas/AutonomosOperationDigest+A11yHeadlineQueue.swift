import Foundation

// Queue headline — peel de AutonomosOperationDigest+A11yHeadlines.

extension AutonomosOperationDigestA11y {
    static func spokenHeadlineQueue(delivered: Int, pending: Int) -> String {
        if delivered > 0 && pending == 0 {
            return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s"), nada pendente"
        }
        if delivered > 0 {
            return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) na fila, segue sem portão"
        }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila, nenhuma entrega comprovada nesta janela"
    }
}
