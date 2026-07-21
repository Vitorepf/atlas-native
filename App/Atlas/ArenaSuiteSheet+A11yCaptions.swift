import Foundation
import AtlasCore

// Captions casos/duração — peel de ArenaSuiteSheet+A11y.

enum ArenaSuiteSheetA11yCaptions {
    static func casesCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let total = engine.casesTotal else { return nil }
        var parts: [String] = []
        if let passed = engine.casesPassed { parts.append("ok \(passed)") }
        if let failed = engine.casesFailed { parts.append("falha \(failed)") }
        parts.append("de \(total) casos")
        return parts.joined(separator: " · ")
    }

    static func durationCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let ms = engine.durationAvgMs else { return nil }
        return "duração média \(ArenaDisplay.duration(ms: ms)) por caso"
    }
}
