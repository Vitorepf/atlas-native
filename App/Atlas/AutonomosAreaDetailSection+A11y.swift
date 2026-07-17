import Foundation
import AtlasCore

/// Spoken labels do detalhe da instância — peel de AutonomosAreaDetailSection (CICLO C).
/// Métricas só quando o payload existe; placement só com campos verificados.

enum AutonomosAreaDetailA11y {
    static func metricDisplay(_ value: Int?) -> String {
        guard let value else { return "—" }
        return "\(value)"
    }

    static func spokenHeader(area: AtlasAutonomosArea, isPaused: Bool?) -> String {
        var parts = [area.areaName]
        let focus = area.focus.trimmingCharacters(in: .whitespacesAndNewlines)
        if !focus.isEmpty { parts.append(focus) }
        parts.append("tier \(area.autonomyTier) de \(area.maxTierForArea)")
        parts.append(spokenPhase(area.loopStatus.phase))
        if let isPaused {
            parts.append(isPaused ? "pausada no runtime" : "ativa no runtime")
        }
        if !area.registered { parts.append("não registrada no servidor") }
        let objective = area.objective.trimmingCharacters(in: .whitespacesAndNewlines)
        if !objective.isEmpty { parts.append(objective) }
        return parts.joined(separator: ", ")
    }

    static func spokenMetrics(cycles: Int?, workOrders: Int?, inbox: Int?) -> String {
        [
            "métricas da instância",
            spokenMetric(label: "ciclos no ledger", value: cycles),
            spokenMetric(label: "tarefas na fila", value: workOrders),
            spokenMetric(label: "itens no inbox", value: inbox),
        ].joined(separator: ", ")
    }

    static func spokenChip(kind: AutonomosDetailSheet, count: Int?) -> String {
        let name = kind.title.lowercased()
        if kind == .budgets {
            return count != nil ? "abrir orçamentos públicos" : "abrir orçamentos, dados não publicados"
        }
        guard let count else { return "abrir \(name), contagens não publicadas" }
        if count == 0 { return "abrir \(name), nenhum item público neste recorte" }
        if count == 1 { return "abrir \(name), 1 item público" }
        return "abrir \(name), \(count) itens públicos"
    }

    static func spokenPlacement(_ placement: AtlasAutonomosRuntimePlacement) -> String {
        var parts = ["onde está rodando"]
        if let host = placement.host, !host.isEmpty { parts.append("host \(host)") }
        if let env = placement.environment, !env.isEmpty { parts.append("ambiente \(env)") }
        if let ws = placement.workspace, !ws.isEmpty { parts.append("workspace \(ws)") }
        if let repo = placement.repository, !repo.isEmpty { parts.append("repositório \(repo)") }
        if let branch = placement.branch, !branch.isEmpty { parts.append("branch \(branch)") }
        if let ttl = placement.leaseTTLSeconds { parts.append("lease \(ttl) segundos") }
        return parts.joined(separator: ", ")
    }

    static func spokenOwnedSystems(_ systems: [String]) -> String {
        "sistemas sob responsabilidade, \(systems.joined(separator: ", "))"
    }

    private static func spokenMetric(label: String, value: Int?) -> String {
        guard let value else { return "\(label) não publicado" }
        return "\(value) \(label)"
    }

    private static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        switch phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
