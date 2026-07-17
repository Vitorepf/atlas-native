import SwiftUI
import AtlasCore

// Cauda frota/saúde/histórico/erro — peel de AutonomosLoadedSection+Stack.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTail: some View {
        runReceiptLines
        loadedStackTailFleet
        loadedStackTailHistory
    }
}
