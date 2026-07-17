import SwiftUI
import AtlasCore

// Input derivado — peel de ArenaRunSheet.

extension ArenaRunSheet {
    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }

    var engines: [String] {
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(composite + suiteEngines)).sorted()
    }

    var input: AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: selectedEngine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason
        )
    }
}
