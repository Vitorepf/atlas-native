import SwiftUI
import AtlasCore

// Suites + run button — peel de AtlasArenaView+Loaded.

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaTail(_ composite: AtlasArenaComposite) -> some View {
        if let scoreboard = model.scoreboard, !scoreboard.suites.isEmpty {
            ArenaSuitesSection(
                scoreboard: scoreboard,
                reduceMotion: reduceMotion,
                onSuiteTap: { selectedSuite = $0 }
            )
        }
        runMeasurementButton
    }
}
