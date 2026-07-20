import SwiftUI
import AtlasCore

// Loaded content — mapa Autônomos v9 (catálogo → hub → evolução).

extension AutonomosView {
    var loadedContent: some View {
        AutonomosMapShell(
            model: model,
            destination: $destination,
            selectedUnitID: $selectedUnitID,
            showNewSheet: $showNewSheet
        )
    }
}
