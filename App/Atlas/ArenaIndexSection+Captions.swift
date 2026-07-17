import SwiftUI
import AtlasCore

// Captions — peel de ArenaIndexSection+Header.

extension ArenaIndexSection {
    var chartEngine: AtlasArenaCompositeEngine? {
        composite.engines.first { engine in
            engine.history.contains { point in
                point.composite != nil || point.withAtlas != nil || point.withoutAtlas != nil
            }
        }
    }

    var coverageCaption: String {
        let base = "cobertura \(composite.suitesMeasured)/\(composite.suitesTotal)"
        guard composite.suitesMeasured < composite.suitesTotal else { return base }
        return "\(base) · parcial"
    }
}
