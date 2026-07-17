import SwiftUI
import AtlasCore

// Visual da row entregue — peel de AutonomosAreaDeliveredSection+Row.
// CycleMeta → AutonomosAreaDeliveredSection+RowVisual+CycleMeta.swift
// GraphHint → AutonomosAreaDeliveredSection+RowVisual+GraphHint.swift

extension AutonomosAreaDeliveredSection {
    func deliveredRow(_ cycle: AtlasAutonomosCycle, graphHint: Bool = false) -> some View {
        HStack(spacing: 8) {
            deliveredRowCycleMeta(cycle)
            deliveredRowGraphHint(cycle, graphHint: graphHint)
        }
        .contentShape(Rectangle())
    }
}
