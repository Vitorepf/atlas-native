import Foundation
import AtlasCore

/// Spoken labels do detalhe da instância — peel de AutonomosAreaDetailSection (CICLO C).
/// Placement/fase → AutonomosAreaDetailSection+A11yPlacement.swift

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
}
