import Foundation
import AtlasCore

/// Spoken labels do detalhe da instância — peel de AutonomosAreaDetailSection (CICLO C).
/// Placement/fase → AutonomosAreaDetailSection+A11yPlacement.swift
/// Chip → AutonomosAreaDetailSection+A11yChip.swift
/// Header → AutonomosAreaDetailSection+A11yHeader.swift

enum AutonomosAreaDetailA11y {
    static func metricDisplay(_ value: Int?) -> String {
        guard let value else { return "—" }
        return "\(value)"
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
