import SwiftUI
import AtlasCore

// Engine list — peel de ArenaRunSheet+Input.

extension ArenaRunSheet {
    var engines: [String] {
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(composite + suiteEngines)).sorted()
    }
}
