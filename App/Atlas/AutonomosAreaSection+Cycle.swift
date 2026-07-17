import SwiftUI

// Helpers + ciclo HStack — peel de AutonomosAreaControls.

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

    func tap(_ action: () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        action()
    }

    func spoken(_ label: String) -> String {
        canControl ? label : "\(label), indisponível"
    }

    func hint(_ text: String) -> String {
        canControl ? text : spokenContainerHint
    }
}
