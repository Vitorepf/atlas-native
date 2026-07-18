import SwiftUI
import AtlasCore

// Start input payload — peel de ArenaRunSheet+Input.

extension ArenaRunSheet {
    /// Representativo (validação/A11y) — mesmos campos de todos os POSTs.
    var input: AtlasArenaStartInput {
        payload(engine: selectedEngines.sorted().first ?? "")
    }

    /// Um POST B5 por motor selecionado (goal 1: motor contra motor).
    var inputs: [AtlasArenaStartInput] {
        selectedEngines.sorted().map(payload(engine:))
    }

    private func payload(engine: String) -> AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: engine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason
        )
    }
}
