import Foundation
import AtlasCore

/// Spoken labels do detalhe da instância — peel de AutonomosAreaDetailSection (CICLO C).
/// Placement/fase → AutonomosAreaDetailSection+A11yPlacement.swift
/// Chip → AutonomosAreaDetailSection+A11yChip.swift

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
}
