import SwiftUI
import AtlasCore

// Installed suites — peel de ArenaRunSheet+Input.

extension ArenaRunSheet {
    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }
}
