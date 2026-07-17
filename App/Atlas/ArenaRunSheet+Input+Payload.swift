import SwiftUI
import AtlasCore

// Start input payload — peel de ArenaRunSheet+Input.

extension ArenaRunSheet {
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
