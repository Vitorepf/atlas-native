import SwiftUI
import AtlasCore

// Seed defaults — peel de ArenaRunSheet+Submit.

extension ArenaRunSheet {
    func seedDefaultsIfNeeded() {
        if selectedSuites.isEmpty, let first = installedSuites.first?.suite {
            selectedSuites.insert(first)
        }
        if engines.isEmpty {
            selectedEngine = ""
        } else if selectedEngine.isEmpty {
            selectedEngine = engines.first ?? ""
        }
    }
}
