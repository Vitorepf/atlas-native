import SwiftUI
import AtlasCore

// Loaded sections — peel de AtlasArenaView+Content.

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaContent(_ composite: AtlasArenaComposite) -> some View {
        ArenaNowSection(liveRuns: model.liveRuns, reduceMotion: reduceMotion)
        if showsIndexSection(composite) {
            ArenaIndexSection(
                composite: composite,
                reduceMotion: reduceMotion,
                onEngineTap: { selectedEngine = $0 }
            )
        }
        ArenaCapabilitiesSection(capabilities: model.capabilities, reduceMotion: reduceMotion)
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
