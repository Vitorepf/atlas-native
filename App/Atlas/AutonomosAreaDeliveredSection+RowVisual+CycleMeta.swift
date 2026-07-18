import SwiftUI
import AtlasCore

// Cycle meta texts — peel de AutonomosAreaDeliveredSection+RowVisual.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredRowCycleMeta(_ cycle: AtlasAutonomosCycle) -> some View {
        // Hex cru fora da tela: a identidade do commit vive no botão que abre
        // o grafo (Atlas Código) — prova preservada pela ação, não pelo hash.
        Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
    }
}
