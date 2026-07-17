import SwiftUI
import AtlasCore

// Delivered row actions — peel de AutonomosAreaDeliveredSection.
// Visual → AutonomosAreaDeliveredSection+RowVisual.swift · Helpers → +Helpers.swift
// Graph → AutonomosAreaDeliveredSection+RowGraph.swift
// Self → AutonomosAreaDeliveredSection+Row+SelfRow.swift

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredCycleRow(cycle: AtlasAutonomosCycle, index: Int, visible: Int, isSelf: Bool) -> some View {
        if isSelf {
            deliveredSelfRow(cycle: cycle, index: index, visible: visible)
        } else {
            deliveredGraphRow(cycle: cycle, index: index, visible: visible)
        }
    }
}
