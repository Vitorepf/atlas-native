import SwiftUI
import AtlasCore

// Conteúdo carregado da Arena — peel de AtlasArenaView (régua ≤110).
// Run → AtlasArenaView+RunButton.swift

extension AtlasArenaView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle where model.composite == nil,
             .loading where model.composite == nil:
            loadingCard
        case .failed where model.composite == nil:
            if model.isDomainUnavailable {
                domainUnavailableCard
            } else {
                networkFailureCard
            }
        default:
            if let composite = model.composite {
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
            } else {
                domainUnavailableCard
            }
        }
    }
}
