import SwiftUI
import AtlasCore

// Graph-open button — peel de AutonomosAreaDeliveredSection+RowGraph.
// Label → AutonomosAreaDeliveredSection+RowGraph+OpenButton+Label.swift
// Action → AutonomosAreaDeliveredSection+RowGraph+OpenButton+Action.swift
// A11y → AutonomosAreaDeliveredSection+RowGraph+OpenButton+A11y.swift

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredGraphOpenButton(
        cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int,
        repo: String
    ) -> some View {
        deliveredGraphOpenA11y(
            Button(action: deliveredGraphOpenAction(cycle: cycle, repo: repo)) {
                deliveredGraphOpenLabel(cycle: cycle)
            }
            .buttonStyle(.plain),
            cycle: cycle,
            index: index,
            visible: visible
        )
    }
}
