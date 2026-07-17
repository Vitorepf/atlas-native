import Foundation
import AtlasCore

// Engine spoken — peel de ArenaSuiteSheet+A11y.

extension ArenaSuiteSheetA11y {
    static func spokenEngine(_ engine: AtlasArenaSuiteEngine) -> String {
        var parts = [engine.engine, "score \(ArenaFormat.score(engine.score))"]
        if engine.regressed { parts.append("regressão detectada") }
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) { parts.append(cases) }
        if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) { parts.append(duration) }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) pontos no histórico")
        }
        return parts.joined(separator: ", ")
    }
}
