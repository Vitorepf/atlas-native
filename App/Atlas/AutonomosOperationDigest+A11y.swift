import Foundation

/// Spoken labels do resumo da operação — peel de AutonomosOperationDigestSection (CICLO C).
/// Agrega só contagens publicadas; incidente só quando `incidentPresent`; achados por risco reais.

enum AutonomosOperationDigestA11y {
    static func spokenSection(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        incidentPresent: Bool,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> String {
        var parts = ["resumo da operação"]
        parts.append(incidentPresent ? "requer você, incidente aguarda decisão" : "por exceção")
        parts.append(spokenHeadline(delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
        if deliveredTotal > 0 {
            parts.append("\(deliveredTotal) entregue\(deliveredTotal == 1 ? "" : "s") comprovada\(deliveredTotal == 1 ? "" : "s")")
        }
        if pendingCount > 0 {
            parts.append("\(pendingCount) tarefa\(pendingCount == 1 ? "" : "s") na fila")
        }
        if inboxCount > 0 {
            parts.append("\(inboxCount) decisão\(inboxCount == 1 ? "" : "ões") aguardando")
        }
        if let oldest = oldestBacklogCreatedAt {
            parts.append("item mais antigo \(AutonomosChrome.relativeAge(from: oldest))")
        }
        if !findingsByRisk.isEmpty {
            parts.append(spokenFindings(findingsByRisk))
        }
        return parts.joined(separator: ", ")
    }

    static func spokenQuiet() -> String {
        "operação quieta, nenhuma entrega pendência ou incidente publicado nesta janela"
    }

    private static func spokenHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return "incidente aguarda sua decisão; frota segue por exceção" }
        if delivered > 0 && pending == 0 {
            return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s"), nada pendente"
        }
        if delivered > 0 {
            return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) na fila, segue sem portão"
        }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila, nenhuma entrega comprovada nesta janela"
    }

    private static func spokenFindings(_ findings: [String: Int]) -> String {
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
