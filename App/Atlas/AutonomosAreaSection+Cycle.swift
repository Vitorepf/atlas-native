import SwiftUI

// Helpers + ciclo HStack — peel de AutonomosAreaControls.
// Helpers → AutonomosAreaSection+CycleHelpers.swift

extension AutonomosAreaControls {
    var cycleButtons: some View {
        HStack(spacing: 8) {
            Button("Novo ciclo · ensaio") { tap(onDryRun) }
                .buttonStyle(AutonomosPrimaryButtonStyle())
                .accessibilityLabel(spoken("novo ciclo ensaio, \(areaName)"))
                .accessibilityHint(hint("inicia ciclo de ensaio sem efeito real"))
            Button("Executar de verdade") { tap(onExecute) }
                .buttonStyle(AutonomosSecondaryButtonStyle())
                .accessibilityLabel(spoken("executar de verdade, \(areaName)"))
                .accessibilityHint(hint("inicia ciclo real com governança"))
        }
    }
}
