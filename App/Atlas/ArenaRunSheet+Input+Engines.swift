import SwiftUI
import AtlasCore

// Engine list — peel de ArenaRunSheet+Input.

extension ArenaRunSheet {
    /// Catálogo B6 (motores rodáveis, inclusive nunca medidos) ∪ já medidos.
    var engines: [String] {
        let catalog = model.engineCatalog?.engines.map(\.engine) ?? []
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(catalog + composite + suiteEngines)).sorted()
    }
}
